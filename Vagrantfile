# -*- mode: ruby -*-
# vi: set ft=ruby :

# ------------------------- CONFIG PARAMS ----------------------------
provider = "virtualbox"      # VM provider
type = "bento/centos-7.2"
RAM = 16384                  # When testing Tachyon
CPUs = 2                     # CPU cores
Name = "ansible"           # name of the master node (used in scripts/spark-env-sh)
# -------------------------- END CONFIG PARAMS -----------------------


Vagrant.configure(2) do |config|
# configure the bootstrap node
  config.vm.boot_timeout = 600 
  config.vm.define Name do |bootstrap|
    bootstrap.vm.box = type
    bootstrap.vm.hostname = Name
    bootstrap.vm.provider provider do |vb|
      vb.memory = RAM
      vb.cpus = CPUs 
      vb.name = Name
    end
    bootstrap.vm.provision :shell, :path => "bootstrap.sh", privileged: false
  end
end
