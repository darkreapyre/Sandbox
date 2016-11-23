# -*- mode: ruby -*-
# vi: set ft=ruby :

# ------------------------- CONFIG PARAMS ----------------------------
provider = "virtualbox"       # VM provider
boxMaster = "ubuntu/trusty64" # system to be installed on master
boxSlave = "ubuntu/trusty64"  # system to be installed on slaves

masterRAM = 6144              # RAM in MB
masterCPUs = 2                # CPU cores
masterName = "master"   # name of the master node (used in scripts/spark-env-sh)
masterIP = "10.20.30.100"     # private IP of master node

slaves = 1                    # number of slaves 
slaveRAM = 6144               # RAM in MB
slaveCPUs = 2                 # CPU cores
slaveName = "slave"     # names of the slave nodes with a number appended
slavesIP = "10.20.30.10"      # private IPs of slaves appending a number

IPythonPort = 8001            # IPython/Jupyter port to forward (set in IPython config)
SparkMasterHostPort = 8880    # SPARK Master Host Port
SparkMasterPort = 8080        # SPARK_MASTER_WEBUI_PORT
SparkWorkerHostPort = 8881    # Spark Worker Host Port
SparkWorkerPort = 8081        # SPARK_WORKER_WEBUI_PORT
SparkAppPort = 4040           # Spark app web UI port
RStudioPort = 8787            # RStudio server port
ZeppelinPort = 8888           # Zeppelin (default is 8080, conflict with Spark)
SlidesHostPort = 8989         # jupyter Host Port
SlidesPort = 8000             # jupyter-nbconvert <file.ipynb> --to slides --post serve
ShinyPort = 3838              # Shiny App Server
# -------------------------- END CONFIG PARAMS -----------------------

Vagrant.configure(2) do |config|
# config master node 
  config.vm.define masterName do |master|
    master.vm.box = boxMaster
    master.vm.hostname = masterName
    master.vm.provider provider do |vb|
      vb.memory = masterRAM
      vb.cpus = masterCPUs 
      vb.name = master.vm.hostname.to_s
    end
    master.vm.network :forwarded_port, host: IPythonPort,     guest: IPythonPort
    master.vm.network :forwarded_port, host: SparkMasterHostPort, guest: SparkMasterPort
    master.vm.network :forwarded_port, host: SparkWorkerHostPort, guest: SparkWorkerPort
    master.vm.network :forwarded_port, host: SparkAppPort,    guest: SparkAppPort
    master.vm.network :forwarded_port, host: RStudioPort,     guest: RStudioPort
    master.vm.network :forwarded_port, host: SlidesHostPort,      guest: SlidesPort
    master.vm.network :forwarded_port, host: ZeppelinPort,    guest: ZeppelinPort
    master.vm.network :forwarded_port, host: ShinyPort,    guest: ShinyPort
    master.vm.network "private_network", ip: masterIP
    master.vm.synced_folder ".", "/vagrant"
    master.vm.provision "shell" do |p|
      p.path = "scripts/provision.sh"
      p.args = "-t MASTER -n #{slaves} -a #{slavesIP} -m #{masterName} -s #{slaveName}"
    end
    master.vm.post_up_message = "Remember to read the README file in your home directory..."
  end

  # config each worker node (slaves)
  (1..slaves).each do |i|
    config.vm.define "#{slaveName}-#{i}" do |node|
      node.vm.box = boxSlave
      node.vm.hostname = "#{slaveName}-#{i}" 
      node.vm.network "private_network", ip: "#{slavesIP}#{i}"
      node.vm.synced_folder ".", "/vagrant"
      node.vm.provider provider do |vb|
        vb.memory = slaveRAM
        vb.cpus = slaveCPUs 
        vb.name = node.vm.hostname.to_s
      end
      node.vm.provision "shell" do |p|
        p.path = "scripts/provision.sh"
        p.args = "-t SLAVE -n #{slaves} -a #{slavesIP} -m #{masterName} -s #{slaveName}"
      end
    end
  end
end
