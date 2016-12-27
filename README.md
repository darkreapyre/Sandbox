# Overview
This document outlines the steps/procedures taken to design, implement and manage a development AWS environment/architecture for the purposes of introducing a new Technical Account Manager (TAM) to AWS for his/her development plan. The architecture of choice is an Internet of Things (IoT) pipeline that can be implemented using four differnt options:
#### Traditional
This phase will involve initially porting the legacy Data Science [“Sandbox”](https://github.com/darkreapyre/Sandbox) onto AWS.
#### Containerized
This phase involves taking said architecture and porting it from an infrastructure-based (IaaS) cloud to Docker containers.
#### Mesosphere
This phase implements the __Phase 2__ environment on top of Mesosphere DC/OS.
#### Serverless
This phase will involve leveraging the various comparable AWS platforms to fully incorporate the solution into AWS by leveraging the various service offerings.
These phases will be implemented by leveraging a number of Infrastructure as Code (IaC) tools in order to simulate any potential customer implementation scenarios:

1. [Vagrant](https://www.vagrantup.com)/[Ansible](https://www.ansible.com)
2. [AWS CloudFormation](https://aws.amazon.com/cloudformation/)
3. [TerraForm](https://www.terraform.io)

Additionally, the objective of this implementation is to leverage the Command-line (CLI) tools, scripts and an AWS WorKSpaces in order to provide an advanced user experience over and above using the AWS Console.

# Pre-requisites
To start, the following components must be configured or installed: 
- [AWS Account](https://aws.amazon.com).

>**Note:** The resources required to run this architecture are beyond the scope of the [AWS Free Tier](https://aws.amazon.com/free/).

- Amazon [WorkSpaces](https://aws.amazon.com/workspaces/) virtual desktop: This avoids the complication of having to work behind firewalls/proxies etc. and allows for a more simulated approach to a customers’ environment. 
- AWS Command Line Interface (CLI) for [Windows](https://s3.amazonaws.com/aws-cli/AWSCLI64.msi).

>**Note:** When installing the 64-bit AWS CLI on AWS WorkSpaces, there may be errors citing code *2503* and/or *2505*. These errors can be corrected by [this](http://winaero.com/blog/fix-msi-installer-errors-2502-and-2503-in-windows-10-windows-8-1-and-windows-7/) procedure .

- [Git client for Windows](https://git-scm.com/).
- [PuTTY and PuTTYgen](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).
- A basic familiarity with using core AWS services particularly:
	- **IAM**
	- **EC2**
	- **WorkSpaces**
	- **S3**

# Configure the AWS CLI and launch the `edge` EC2 instance
After configureing and downloading the above pre-requisites, the following procedures will walk through setting up the basic EC2 instance, the `edge` node. This instance is essentially a jump start into the AWS cloud. It is the instance that will allow for initial deployment of the architecture and can at a later stage be used as the VPN edge point into a VPC, a ssh bastion/jump host allowing for "local" code to be pushed to the cloud or simply just a "backdoor" into the environment. For more information on securing and providing access into the architecture, see [Appendix A][]. Testing a footnote.[^1]

### Step 1: Configure the AWS CLI
From the Windows command prompt, type `aws configure`. The CLI will prompt for the following:
- **AWS Access Key ID:** The Access Key ID for the AWS account that is being used to configure the `admin` instance.
- **AWS Secret Access Key:** The Secret Access Key for the AWS account being used to configure the `admin` instance.
- **Default region name:** This is the AWS region where the `edge` instance will be configured. This can be any region, but it is recommended to choose the region closest to you.
- **Default output format:** This is the format of the results from running a CLI command. It can be formatted as `json`, `text` or `table`. It is recommended that for **Step 1**, to have the output formatted as `text` to better familiarize oneself with using the CLI.

>**Note:** To configure multiple profiles, named profiles can be configured with the `--profile <profile name>` option. Additionally, to change any of the above options, simply run `aws configure` again.

### Step 2: Create a Security Group for the EC2 Instance
The next step is to configure the pre-requisites for launching an EC2 instance in order for it to be accessible. From the command prompt execute:
```
> aws ec2 create-security-group --group-name devenv-sg --description "Security Group for DSIoT Architecture"
```
>**Note:** The output from the above command will be the randomly generated security group ID. Make sure to take note of the ID for future steps.

### Step 3: Allow incoming traffic over port 22 for SSH
The next step is to authorize the newly created security group to accept **incoming** traffic via tcp port 22, the default port for SSH. Execute the following to accomplish this:
```
> aws ec2 authorize-security-group-ingress --group-name devenv-sg --protocol tcp --port 22 --cidr 0.0.0.0/0
```

>**Note:** The above command authorizes a SSH connection from anywhere. In order to more securely lock down the connection, it is recommended to use the network address from the subnet on which the AWS WorkSpaces desktop is configured.

### Step 4: Confirm the security group configuration
To get an overview of the security group configuration for the instance, execute the following:
```
> aws ec2 describe-security-groups --filters "Name=group-name, Values=devenv-sg"
```

### Step 5: Create the key pair to connect to the EC2 instance
Even though the security group allows a SSH connection from any network, a private key is still required too access the EC2 instance. To create the key pair and save it to a file called `devenv-key.pem`, execute the following:
```
> aws ec2 create-key-pair --key-name devenv-key --query "KeyMaterial" --output text > devenv-key.pem
```

### Step 6: Find the Amazon Image ID (AMI) for the `admin` node
For the `edge` node configuration  a `t2.micro` instance will be used. To find the latest AMI for the `t2.micro`, run the following command:
```
> aws ec2 describe-images --owners amazon --filters "Name=root-device-type, Values=ebs" "Name=architecture, Values=x86_64" "Name=virtualization-type, Values=hvm" "Name=description, Values='*Amazon*Linux*'" "Name=name, Values='*amzn-ami-hvm-2016.09.1*gp2'" --query "Images[*].{ID:ImageId}"
```
The above command will filter all Amazon owned AMI Instances for the *x86_64* architecture; *EBS-Backed*; was part of the  *2016.09.1* point release cycle; has *Amazon Linux* in the description and query to produce the resultant AMI ID. Take note of the latest AMI ID.

### Step 7:  Launch the `admin` node instance
Using both the AMI ID noted above and the Security Group ID from **Step 2**, create the `admin` node EC2 Instance by executing the following:

```
> aws ec2 run-instances --image-id ami-XXXXXXXXX --security-group-ids sg-XXXXXXXX --count 1 --instance-type t2.micro --key-name devenv-key --query "Instances[0].InstanceId"
```
The output from the above command will be the output the newly created instance ID of the `admin` node. Make sure to take note of it for future usage.

>**Note:** *ami-XXXXXXXX* and *sg-XXXXXXXX* should be replaced with the output from **Step 6** and **Step 4** respectively.

### Step 8: Allocate an Elastic IP Address for EC2-VPC
Since the `t2.micro` instance type requires a VPC and considering that the `admin` node must have a decimated IP address that persists across reboots, an Elastic IP must be allocated using the following command line:
```
> aws ec2 allocate-address --domain vpc
```
The output from the above command will be the `PublicIp` assigned to the *devenv* as well as the `AllocationId`. Make sure to take note of both of these as they will be required for future use. If for some reason reference to these id's are lost or forgotten, use the following command to view the information:
```
> aws ec2 describe-addresses --filters "Name=domain,Values=vpc"
```

### Step 9: Associating the Elastic IP with the `admin` node
To associate the Elastic IP to the running `edge` node instance, execute the following:
```
> aws ec2 associate-address --instance-id i-XXXXXXXX --allocation-id eipalloc-XXXXXXXX
```

>**Note:** *i-XXXXXXXX* and *eipalloc-XXXXXXXX* should be replaced with the output from **Step 7** and the output from the `describe-addresses` command in **Step 8**.

### Step 10: Assign a name to the `admin` node
Assign the `edge` node it's name by aexecuting the following command:
```
> aws ec2 create-tags --resources i-XXXXXXXX --tags "Key=Name,Value=edge" 
```

>**Note:** *i-XXXXXXXX* should be replaced with the EC2 Instance ID created in __Step 7__.

### Step 11: Connecting to the `edge` node
Now that the `edge` node has been created, it up and running and has a public IP allocated to it, the next step is to connect via SSH. For the sake of this step, the *ssh* client that comes with the [Git BASH](https://git-scm.com/) client. To do this, execute the following:
- Open the *Git BASH* application.
- Navigate to the location of the `devenv-key.pem` file and execute the following:
```
$ ssh -i devenv-key.pem ec2-user@XXX.XXX.XXX.XXX
```

>**Note:** *XXX.XXX.XXX.XXX* should be replaced with the `PublicIp` noted in **Step 8**. Additionally, for information on how to use *PuTTY* instead of *Git BASH* can new found [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html).

To shut down the `edge` node from the AWS CLI, run the following:

```
> aws ec2 stop-instances --instance-ids i-XXXXXXXX
```

To start the `edge` node from the AWS CLI, run the following:

```
> aws ec2 start-instances --instance-ids i-XXXXXXXX
```

To check if the instance is actually *stopped* before executing any of the abopve copmmands, execute the following:

```
> aws ec2 describe-instances --filter "Name=instance-state-name,Values=stopped"
```

### Step 12: Preparing for Provisionning
After connecting to the `edge` node, chnage to the current working directory for the `ec2-user` and set up the [Sanbox](https://git.com/darkreapyre/Sandbox.git) repository by running the following:

```
# Change to working directory of the .pem file
$ cd <location of devenv-key.pem>

# Copy the .pem file to the `admin` node
$ scp -i devenv-key.pem devenv-key.pem ec2-user@<XXX.XXX.XXX.XXX>:/tmp

# ssh to the `admin` node
$ ssh -i devenv-key.pem ex2-user@<XXX.XXX.XXX.XXX>

# Download the Architecture and Deployment code
$ git clone https://github.com/darkreapyre/Sandbox.git
$ cd Sandbox
$ mv /tmp/devenv-key.pem .
```
Now that the `edge` node is ready, it can be leveraged to deploy any of the above mentioned architectures using a number of the deplyment options. The next sections will describe each of the possible architectures to choose as well as how to leverage the different deployment tools within each architecture.

---
# Traditional Iaas Architecture

```
export AWS_KEY='your-key'
export AWS_SECRET='your-secret'
export AWS_KEYNAME='devenv-key'
export AWS_KEYPATH='~/Sandbox/devenv-key.pem'
```

---
# Containerized GPU Architecture

---
# Mesosphere DC/OS Architecture

---
# NoOps Architecture

---

# [Appendix A]: Considerations for Securing the Environment

[^1]: Footnorte reference 