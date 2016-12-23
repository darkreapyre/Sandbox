# Overview
This document outlines the steps/procedures taken to design, implement and manage a development AWS environment/architecture for the purposes of introducing a new Technical Account Manager (TAM) to AWS for his/her development plan. The architecture of choice is an Internet of Things (IoT) pipeline that will evolve over three phases:
#### Phase 1: Legacy
This phase will involve initially porting the legacy Data Science [“Sandbox”](https://github.com/darkreapyre/Sandbox) onto AWS.
#### Phase 2: Containers
This phase involves taking said architecture and porting it from an infrastructure-based (IaaS) cloud to Docker containers.
#### Phase 3: Serverless
This phase will involve leveraging the various comparable AWS platforms to fully incorporate the solution into AWS by leveraging the various service offerings.
These phases will be implemented by leveraging a number of Infrastructure as Code (IaC) tools in order to simulate any potential customer implementation scenarios:

1. [Vagrant](https://www.vagrantup.com)
2. [Ansible](https://www.ansible.com)
3. [AWS CloudFormation](https://aws.amazon.com/cloudformation/)
4. [TerraForm](https://www.terraform.io)

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

# Getting Started
After configureing and downloading the above pre-requisites, the following procedures will walk through setting up the basic environment:
## Configure the AWS CLI and launch the **admin** EC2 instance
### Step 1: Configure the AWS CLI
From the Windows command prompt, type `aws configure`. The CLI will prompt for the following:
- **AWS Access Key ID:** The Access Key ID for the AWS account that is being used to configure the **admin** instance.
- **AWS Secret Access Key:** The Secret Access Key for the AWS account being used to configure the **admin** instance.
- **Default region name:** This is the AWS region where the **admin** instance will be configured. This can be any region, but it is recommended to choose the region closest to you.
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
> aws authorize-security-group-ingress --group-name devenv-sg --protocol tcp --port 22 --cidrr 0.0.0.0/0
```

>**Note:** The above command authorizes a SSH connection from anywhere. In order to more securely lock down the connection, it is recommended to use the network address from the subnet on which the AWS WorkSpaces desktop is configured.

### Step 4: Confirm the security group configuration
To get an overview of the security group configuration for the instance, execute the following:
```
> aws ec2 describe-security-groups
```

### Step 5: Create the key pair to connect to the EC2 instance
Even though the security group allows a SSH connection from any network, a private key is still required too access the EC2 instance. To create the key pair and save it to a file called `devenv-key.pem`, execute the following:
```
> aws create-key-pair --key-name devenv-key --query "KeyMaterial" --output text > devenv-key.pem
```

### Step 6: Find the Amazon Image ID (AMI) for the **admin** node
For the **Admin** node configuration  a `t2.micro` instance will be used. To find the latest AMI for the `t2.micro`, run the following command:
```
> aws ec2 describe-images --owners amazonm --filters "Name-root-device-type,Values=ebs"
```
<!---
Make sure to execute the above and double check what the output is so as to add it to the comments below
--->
From the output of the above command, take note of the latest AMI ID for the `t2.micro` instance.

### Step 7:  Launch the **admin** node instance
Using both the `t2.micro` AMI ID noted above and the Security Group ID from **Step 2**, create the **admin** node EC2 Instance by executing the following:
<!---
Make sure to to run the describe-instances command to replace the X's below with the actual instance ID
--->
```
> aws ec2 run-instances --image-id ami-XXXXXXXXX --security-group-ids sg-XXXXXXXX --count 1 --instance-type t2.micro --key-name devenv-key --query "Instances[0].InstanceId"
```
The output from the above command will be the output the newly created instance I'd of the **admin** node. Make sure to take note of it for future usage.

>**Note:** *ami-XXXXXXXX* and *sg-XXXXXXXX* should be replaced with the output from **Step 6** and **Step 4** respectively.

### Step 8: Allocate an Elastic IP Address for EC2-VPC
Since the `t2.micro` instance type requires a VPC and considering that the **admin** node must have a decimated IP address that persists across reboots, an Elastic IP must be allocated using the following command line:
```
> aws ec2 allocate-address --domain vpc
```
The output from the above command will be the `PublicIp` assigned to the *devenv* as well as the `AllocationId`. Make sure to take note of both of these as they will be required for future use. If for some reason reference to these id's are lost or forgotten, use the following command to view the information:
```
> aws ec2 describe-addresses --filters "Name=Domain,Values=vpc"
```

### Step 9: Associating the Elastic IP with the **admin** node
To associate the Elastic IP to the running **admin** node instance, execute the following:
```
> aws ec2 associate-address --instance-id i-XXXXXXXX --allocation-id eipalloc-XXXXXXXX
```
<!---
Confirm the suffix for the AMI and EIP
--->

>**Note:** *i-XXXXXXXX* and *eipalloc-XXXXXXXX* should be replaced with the output from **Step 7** and the output from the `describe-addresses` command in **Step 8**.

### Step 10: Connecting to the **admin** node
Now that the **admin** node has been created, it up and running and has a public IP allocated to it, the next step is to connect via SSH. For the sake of this step, the *ssh* client that comes with the [Git BASH](https://git-scm.com/) client. To do this, execute the following:
- Open the *Git BASH* application.
- Navigate to the location of the `devenv-key.pem` file and execute the following:
```
$ ssh -i devenv-key.pem ec2-user@XXX.XXX.XXX.XXX
```

>**Note:** *XXX.XXX.XXX.XXX* should be replaced with the `PublicIp` noted in **Step 8**. Additionally, for information on how to use *PuTTY* instead of *Git BASH* can new found [here](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html).

## Preparing for Deployment