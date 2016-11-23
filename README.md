# Installing a DataStax Analytics and Flink Complex Event Processing Cluster on VMware vSphere
__WORK IN PROGRESS!__  
## Introduction
This document details the process of setting up an ansible control node with `Vagrant` and connecting to a __Vmware vSphere 6.0__ environment to configure a virtualized Big Data ecosystem for the purpose of using it during Data Science for the Internet of Things (DSIoT) course. It further details how to leverage the ansible control node to build out the environment using __ansible playbooks__ with the following:

- Jupyter 4.0.6
- Zeppelin 0.7-SNAPSHOT
- Python 2.7
- Scala 2.10.5
- R __TBD__
- RStudio Server 0.99.491
- RStudio Shiny Server 1.4.1.759
- Java 8
- DataStax Enterprise 5.0.1 (incl. Cassandra 3.0; Titan Graph __VERSION TBD__, Spark 1.6.1 and Solr __VERISON TBD__)
- DataStax Opscenter 6.0
- Flink 1.0

This documnet further details some of the additional processes and tools used in order to fully leverage the architecture, 

## Configuration Overview
### Requirements
The following are the basic components needed to start.

1. A working vSphere 6.0 environment
2. Vagrant 1.8.4
3. vagrant-vsphere Plugin
4. Ubuntu 14.04 (Trusty)
5. DHCP server on the subnet that will the virtual machines.

### Create an Ubuntu Template  
#### Virtual Machine Configuration
Below are the recommended virtual machine configuration settings to ensure that all hardware reuquirements are met:
- 16 vCPU
- 64GB Virtual RAM
- 250GB Virtual Disk

#### Ubuntu Installation and Configuration
Creating the template for Vmware is exactly the same as creating a Vagrant "box". Therefore, the following is [based on](https://blog.engineyard.com/2014/building-a-vagrant-box) that process. After creating the *trusty-tmp* virtual machine, power it up, login and perform the following:  
- Install VMware Tools. As a good practice it is suggested to add some of the basic tools to the template, even if these are part of the overall deployment process later.
```sh
$ sudo apt-get install open-vm-tools git zip unzip wget curl acl
```
- Configure the `root` and `vagrant` users
```sh
$ sudo passwd root # set to vagrant
$ sudo visudo -f /etc/sudoers.d/vagrant
$ vagrant ALL=(ALL) NOPASSWD:ALL
```
- Update the System.
```sh
$ sudo apt-get -y update
$ sudo apt-get -y upgrade
$ sudo shutdown -r now
```
- Install the Public Vagrant SSH Key
```sh
$ mkdir -p /home/vagrant/.ssh
$ chmod 0700 /home/vagrant/.ssh
$ wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
$ chmod 0600 /home/vagrant/.ssh/authorized_keys
$ chown -R vagrant /home/vagrant/.ssh
```
- Install and Configure OpenSSH Server (If not installed during intial Ubuntu installation)
.
```sh
$ sudo apt-get -y install openssh-server git zip unzip curl wget acl
```
- Edit `/etc/ssh/sshd_config` and uncomment the following line
```sh
AuthorizedKeysFile %h/.ssh/authorized_keys
```
- Restart the `ssh` server
```sh
$ sudo service ssh restart
```
- Remove the `trusty-tmp` entry in `/etc/hosts`
- Shut down the server and convert it to a template
```sh
$ sudo shutdown now
```

### Configure the Ansible Control node
A dedicated Ansible Control node is required to load and execute the Ansible deployment. To this end a dedicated Vagrant virtual machine (Centos 7.2) is created.  
To launch the Ansible Control node without starting the cluster deployment:

1. Edit the `bootstrap.sh` file in the root directory, and comment out the last line as follows:
```sh
#vagrant up --no-parallel
```
2. Start the Ansible Control node by typing:
```sh
$ vagrant up
```

During the installation process, Vagrant, Ansible and the necessary Python API's to communicate with VMware are installed as well as the `provision` directory is copied to the Ansible Control node. This directory contains all the necessary code to deploy the cluster. 

```
provision
+--example_box        <-- Vagrant metadata for the vSphere Template
|  +--dummy.box
+--roles              <-- Ansible Roles for the various cluster components
|  +--dsbox
|  +--dse
|  +--opsecenter
+--init.yml           <-- Cluster-wide configuration variables (vSphere Usernames; Passwords; Software versions etc.)
+--site.yml           <-- Cluster-wide Ansible Playbook
+--Vagrantfile        <-- Vagrant deployment file for vSphere cluster nodes
```

The next section describes the above components and how to build them.

## Cluster Deployment Configuration and Setup
### Configure Vagrant to deploy the vSphere Template
Using the Vagrant system, locate the `example_box`. This *dummy* box should have been created when installing the _vagrant-vsphere_ plugin and will typically be located in the ~/.vagrant.d/gems/gems/vagrant-vsphere-1.6.0/ directory. Once located, perform the following:  
- Create the _dummy box_.
```sh
$ cd ~/.vagrant.d/gems/gems/vagrant-vsphere-1.6.0/example_box
$ tar cvfz dummy.box ./metadata.json
```
- Make a new in directory your `<Vagrant Configuration Directory> (e.g. provision)` to start creating the new box and additional configuration files.
```sh
$ cd /`<Vagrant Configuration Directory>`
$ mkdir -p example_box
```
- Move the *dummy box* to this location.
```sh
$ mv dummy.box example_box/
```
- Create a `Vagrantfile` for the *dummy.box*.
```sh
$ cd example_box
$ touch Vagrantfile
```
- Create the configuration as follows, while making the necessary adjustments that are specific to your vSphere environment.
```
  Vagrant.configure("2") do |config|
    config.vm.box = 'vsphere'
    config.vm.box_url = './example_box/dummy.box'
    config.vm.provider :vsphere do |vsphere|
      # The host we're going to connect to
      vsphere.host = '<ESXi Host>'
      # The host for the new VM
      vsphere.compute_resource_name = '<vSphere Cluster>'
      # The resource pool for the new VM
      vsphere.resource_pool_name = 'VagrantVMs'
      # The template we're going to clone
      vsphere.template_name = 'photon-tmp'
      # The name of the new machine
      vsphere.name = 'admin-node'
      # vSphere login
      vsphere.user = 'administrator@vsphere.local' 
      # vSphere password
      vsphere.password = '<vSphere Administrator Passowrd>'
      # If you don't have SSL configured correctly, set this to 'true'
      vsphere.insecure = true
    end
  end
```
- Launch the virtual machines.
```sh
$ vagrant up --provider=vsphere
```
__Note:__ As is highlighted below, The Vagrantfile has ansible parameters that should only be executed after all the last virtual machine has been provisioned. Using the `vagrant up` command will provision the virtual machines in parallel. To ensure that that the provisioning is executed one node at a time, execute the following:
```sh
$ vagrant up --no-parallel
```

### Configure the Ansible Cluster-wide variables: __init.yml__
The key variables used across the cluster are:
- Total: The total number of vSphere Virtual Machines to provision.
	- It is recommended to have a total of 10. 
	- The fist vm is the *admin* node. This vm has DataStax OpsCenter and the other data science libraries; Jupyter; Zeppelin etc.
	- VM 2 through 6 are for the the  DataStax Enterprise/Spark/Graph/Solr nodes.
		- *dse-1* though *dse-5*.
	- VM 7 is the Flink master and  vm's 8 through 10 are the Flink slaves.
		- *flink-0* though *flink-38
	- Should __only__ the DataStaxe Enterprise nodes be required, then the *Total* should be set to to less than 7.
- Username/Password: The username and password credentials for the VMware vSphere environment.
- Cluster: The vSphere cluster on which these vm's will run.
- Host: The vCenter server to connect to.
- Master_User/Master_Pass: These are the credentials that will configured across all nodes within the cluster. The default username and password for this implementation is:
	- Username: *admin*
	- Password: *ADMIN*
- Software Versions: These are the various tested software versions for these architectures.

### Configure Vagrant Ansible provisioner variables: __Vagrantfile__
In order to hand-off to Ansible and allow for coordination between the various roles, the *Vagrantfile* contains the following Ansible specific code:

```
groups = {
  "dse" => [],
  "flink" => [],
  "admin" => [],
  "all_groups:children" => ["dse", "flink", "admin"]
}
...

      if i == Total
        config.vm.provision :ansible do |ansible|
          ansible.playbook = "site.yml"
          ansible.groups = groups
          ansible.extra_vars = {
            "dse_version" => DSE_Version,
            "spark_version" => Spark_Version,
            "maven_version" => Maven_Version,            
            "cluster_user" => Master_User,
            "cluster_password" => Master_Password
          }
          ansible.limit = "all"
          ansible.verbose = "v"
          ansible.raw_ssh_args = ['-o ControlPersist=30m']
        end
      end
...
```

The code above, creates the three separate groups of cluster nodes.
- *dse*: This group contains that nodes that will run the DataStaxe Enterprise suite.
- *flink*: This group contains the Flink and Kafka nodes.
- *admin*: This groups contains the admin node.
- *all*: This group contains all the sub-groups and therefore all the node.

Additionally, the code above, passes dynamically creates *host_vars* for Ansible. This allows the various parameters to be changed in the __init.yml__ file as opposed to hard coding all the host specific characters. Since there is no vSphere Linux orchestration is this configuration, the TCP/IP addresses will be handled by DHCP. This alleviates having to hard code the TCP/IP address and SSH connection specific parameters into a hard-coded *host_vars*.

Some of these host parameters can be optionally changed to adjust the provisioning, e.g.
- [*ansible.limit*](http://docs.ansible.com/ansible/playbooks_best_practices.html#top-level-playbooks-are-separated-by-role):
	- Limits the provisioning to a specific subset of hosts.
	- The default for this configuration is __all__ hosts.
- [*ansible.verbose*](http://docs.ansible.com/ansible/guide_vagrant.html):
	- Displays the degree to which ansible-playbook commands are displayed.
	- The default for this configuration is is to display the basic command and it's result.
- *ansible.raw_ssh_args*:
	- These arguments instruct Ansible to apply a list of OpenSSH client options.
	- The default for this configuration is to persist the SSH configuration for 30 minutes.

A list of the various options that can be used is found [here](https://www.vagrantup.com/docs/provisioning/ansible.html).

### Cluster-wide Ansible Playbook: __site.yml__
After the last virtual machine has been brought online, the Ansible Controller will initialize the cluster by executing the following:

1. Create the cluster administrator on all virtual machines and enable/configure SSH access.
2. Execute the *dse* (DataStax Enterprise) role on all the members of the `dse` group:
	- Install the necessary packages required for DataStax Enterprise.
	- Add the necessary repositories for Oracle Java 8 and DataStax Enterprise.
	- Install Oracle Java 8.
	- Install DataStax Enterprise.
	- Enable Spark, Graph and Solr.
	- Start DataStax Enterprise.
3. Execute the *opscenter* (DataStax OpsCenter) role on the `admin` group:
	- Install the necessary packages for DataStax OpsCenter.
	- Add the necessary repositories for Oracle Java 8 and DataStax OpsCenter.
	- Install Oracle Java 8.
	- Install DataStax OpsCenter.
	- Start DataStax OpsCenter.
4. Execute the *admin* (Data Science Tools and Libraries) role on the `admin` group:
	- Install the necessary programming languages and frameworks:
		- Ruby
		- Node.js
		- Python
		- R
		- Maven
	- Install Spark 1.6.1 to be used only as the Spark client.
	- Install the necessary components to __manually__ install Zeppelin (See Appendix A).
	- Install Jupyter Notebook with the following kernels.
		- Python 2
		- Python 3
		- Scala 2.10
		- R
	- Install R Studio Server.
	- Install R Studio Shiny Server.
5. FLNK -> To-do
6. KAFKA -> To-do

## Cluster Usage

### Spark

### OpsCenter

### Jupyter
The Jupyter Server has been pr-configured with the necessary kernels for Data Science:
- Python2
- Python3
- Scala 2.10
- R

The `notebook` server can be started by executing:
```sh
$ jupyter notebook
```
It is however recommend to launch the `notebook` by using the pre-configured script:
```sh
$ /home/admin/scripts/start-pyspark-notebook.sh
```

This script already has all the needed configuration settngs that have been optimized for Spark Workers, Spark Master and the required packages and "jars" for usage with Cassandra. Once either of these commands are executed, the notebook server is accessible at `http://<Admin server address>:8001`.

### R Studio Server
:8787
### R Studio Shiny Server
:3838
### Zeppelin (see Appendix A)

### FLINK???

### KAFKA???

# Appendix A: Manually Install Zeppelin
Since building Zeppelin can take a while, it is recommended to manually build it, if required.

## Building Zeppelin
The architecture deployment will already have cloned the project onto the `admin` node, in the `/home/admin/apps/` directory. The following build steps will also include `Python` and `R` support via `PySpark` and `SparkR` respectivley:
```sh
$ cd /home/admin/apps/incubator-zeppelin
$ mvn clean package -Pspark-1.6 -Ppyspark -Psparkr -DskipTests
$ ./bin/zeppelin-daemon.sh start
```

## Configuring Zeppelin
Once started, the Zeppelin UI is accessable at http://<Admin Node Address>:8080. Perform the following to configure the environment:
1. Navigate to the Interpreter page. 
2. Enter `spark` for the Spark Interpreter and click `Edit`.
3. Add a new paramter `spark.cassandra.connection.host` with the value set to the IP Address of the Spark Master.
4. Click the `Save` button.
5. Enter `cassandra` for the Cassandra Interpreter and click `Edit`.
6. Change the value of `cassandra.cluster` to `MyCassandraCluster`.
7. Chnage the value of `cassandra.hosts` to the IP Address of the Spark Master.
8. Click the `Save` button.

Zeppelin is now configured for usage with Spark and Cassandra.

# Appendix B: Create a "fat" jar for the spark-cassandra-connector
## Background
In order to connect Spark and Cassandra together, the [`spark-Cassandra-connector`](https://github.com/datastax/spark-cassandra-connector), is required. In the majority of use cases, like the `PySpark` Shell, `Jupyter` (using the Python Kernel) and `zeppelin` (using the Spark or PySpark Interpreter), using the Spark Package with the `--packages` command works. This however is not the case when using `spark-shel`, `spark-submit` or the `Scala` Kernel/Interpreter respectively. 

The reason is that Spark comes pre-installed with [Guava 14.0.1](http://mvnrepository.com/artifact/org.apache.spark/spark-core_2.10/1.6.1), while the connector uses [Guava 16.0.1](http://mvnrepository.com/artifact/com.datastax.spark/spark-cassandra-connector_2.10/1.6.0) and when trying to leverage the connector, we get the following error:
```sh
Caused by: java.lang.IllegalStateException: Detected Guava issue #1635 which indicates that a version of Guava less than 16.01 is in use.  This introduces codec resolution issues and potentially other incompatibility issues in the driver.  Please upgrade to Guava 16.01 or later.
```

When searching for a solution, there are a number of references to shading the spark-cassandra-connector's version of Guava. (A very good explanation of shading in this context, can be found [here](https://hadoopist.wordpress.com/2016/05/22/how-to-connect-cassandra-and-spark/). Unfortunately none of the solutions that were found, actually worked. Therefore, the following details how to make the connector work within the context of this architecture.

## Proceedure for building the assembly jar
In order to compile the assembly or "fat" jar, we need to do the following:
1. Download and install the Scala build tool, `sbt` On the *admin* node.
```sh
$ echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
$ sudo apt-get update
$ sudo apt-get install sbt
```
2. Download the source for the spark-Cassandra-connector and checkout the latest release, branch b1.6.
```sh
$ git clone https://github.com/datastax/spark-cassandra-connector.git
$ cd spark-Cassandra-connector
$ git checkout b.1.6
```
3. Navigate to the `project` directory and open the `Settings.scala` file and navigate to the following lines.
```
...

        case x => old(x)
      }
    }
  )

...

```
4. Insert the following lines and save the file.
```
...

        case x => old(x)
      }
    },
    assemblyShadeRules in assembly := {
      val shadePackage = "shade.com.datastax.connector"
      Seq(
        ShadeRule.rename("com.google.**" -> s"$shadePackage.google.@1").inAll
      )
    }
  )

...

```
5. Still within the `project` directory, open the `plugins.sbt` and add the following to the end of the file bad save it.
```
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.3")
```
6. Navigate to the `spark-cassandra-connector` directory and execute the following to build the assembly jar.
```sh
$ sbt assembly
```
7. The assembly jar is will be generated to to the following directory:
```sh
spark-cassandra-connector/target/scala-{binary.version}/
```

## Using the assembly jar
In order to use the spar-cassandra-connector, simply add the `--jars /path/to/fat/jar/spark-cassandra-connector-1.6.0_2.19.jar` to the `spark-submit` or `spark-shell` command to shade out Guava 16 and use the version provided with spark.