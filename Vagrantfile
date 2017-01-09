# -*- mode: ruby -*-
# vi: set ft=ruby :

# ------------------------- CONFIG PARAMS ----------------------------
provider = "virtualbox"      # VM provider
type = "ubuntu/trusty64"
RAM = 8192                   # 
CPUs = 2                     # CPU cores
Name = "admin"               # name of the config node (used in scripts/spark-env-sh)
IPythonPort = 8001            # IPython/Jupyter port to forward (set in IPython config)
RStudioPort = 8787            # RStudio server port
ZeppelinPort = 8888           # Zeppelin (default is 8080, conflict with Spark)
SlidesHostPort = 8989         # jupyter Host Port
SlidesPort = 8000             # jupyter-nbconvert <file.ipynb> --to slides --post serve
ShinyPort = 3838              # Shiny App Server

# -------------------------- END CONFIG PARAMS -----------------------


Vagrant.configure(2) do |config|
# configure the Admin node
  config.vm.boot_timeout = 600 
  config.vm.define Name do |bootstrap|
    bootstrap.vm.box = type
    bootstrap.vm.hostname = Name
    bootstrap.vm.provider provider do |vb|
      vb.memory = RAM
      vb.cpus = CPUs 
      vb.name = Name
    end
    bootstrap.vm.network :forwarded_port, host: IPythonPort,     guest: IPythonPort
    bootstrap.vm.network :forwarded_port, host: RStudioPort,     guest: RStudioPort
    bootstrap.vm.network :forwarded_port, host: SlidesHostPort,      guest: SlidesPort
    bootstrap.vm.network :forwarded_port, host: ZeppelinPort,    guest: ZeppelinPort
    bootstrap.vm.network :forwarded_port, host: ShinyPort,    guest: ShinyPort
    bootstrap.vm.network :forwarded_port, host: SlidesPort,    guest: SlidesPort
    bootstrap.vm.provision :shell, :path => "bootstrap.sh", privileged: false
  end
end
