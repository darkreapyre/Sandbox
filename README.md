# Data Science at Scale with Spark
## Introduction  
This document highlites how to leverage Vagrant to deploy a small Spark cluster for Data Science. It is based on [dsbox] from [Marcus Colebrook], but with a lot of extras. 
This is a Linux (Ubuntu) box deployed by vagrant including the following Data Science apps:
- [Spark] 1.5.2: one master node and up to 9 slaves.
- [Jupyter] 4.1.0 (IPython 4.0.1): kernels for Python 2 & 3, R, and Scala 2.10. It also includes [RISE], [test_helper], and [IPython-extensions].
- [Python] 2.7 and 3.4.
- [R] version 3.3.0 (2016-03-30) -- "Supposidley Educational".
- [RStudio Server] v0.99.491.
- [Rstudio Shiny Server] v1.4.2.789 -- Intstall `ubuntu/trusty64`
- [Java JDK 7] (1.7.0_91).
- [Oracle Java JDK 8] (1.8.0_91).
- [Scala] 2.10.
- [TensorFlow] 0.8.0.
- [Theano] 0.8.1.
- [Datastax Distribution of Apache Cassandra] 3.5.

It has been succesfully tested on both `OSX El Capitan` and `Windows 7` systems. __Note:__ When running on `Windows 7`, ensure you have __VirtualBox 4.3.34__ loaded. This environment does not work on version __5.x__ for Windows. 

__PLEASE NOTE:__ This realease does not include __Hadoop__ or the __Hadoop Distributed Filesystem (HDFS)__. In order to share data between cluster nodes, it is recommended that you copy the data to the `<YOUR_SPARK.LOCAL_FOLDER>`. Once there, all cluster nodes will be able to access the data locally at the `/vagrant` [synced folder], for example (in Python):
```
data = sc.textFile("file:///vagrant/data.csv")
```
## Pre-deployment steps
To install the box, you must follow the next steps:

1. Install [VirtualBox]: if you use any other provider, you must change the `provider` parameter in the Vagrantfile.
2. Install [Vagrant] 1.8.1.
3. Install [Git].
4. Clone this repository to a specific folder:
```sh
$ git clone https://github.com/darkreapyre/Big-Data-Architectures.git <YOUR_BOX_FOLDER>
cd Spark.local
```
__Note:__ If running `Vagrant` on `Windows 7`, be sure Unix Style line endings. If you experience issues with line-ending (see [GitHub Help]) after cloning and starting up the box, to resolves this problem, and __BEFORE CLONING__ the box, type:
```sh
 $ git config --global core.autocrlf input 
```
Additionally, if running `Vagrant` on `OSX`, ensure to run the following command on the provisioning scripts __BEFORE__ starting the installation:
```sh
$ cd <YOUR_SPARK.LOCAL_FOLDER>/scripts/
$ chmod +x *.sh
```

## Config parameters
Go to `<YOUR_SPARK.LOCAL_FOLDER>`, and edit the `Vagrantfile` to change the parameters: 

| Parameter  | Description | Default value |
|------------|-------------|:-------------:|
| *provider* | VM provider  | "virtualbox" |
| *boxMaster* | OS in master node | "ubuntu/trusty64" |
| *boxSlave* | OS in slave nodes | ubuntu/trusty64 |
| *masterRAM* | Master's RAM in MB | 40967 |
| *masterCPU* | Master's CPU cores | 2 |
| *masterName* | name of the master node used in `scripts/spark-env-sh` | "master" |
| *masterIP* | private IP of master node | "10.20.30.100" |
| *slaves*| # of slaves | 2 (max 9) |
| *slaveRAM* | Slave's RAM in MB | 2048 |
| *slaveCPU* | Slave's CPU cores | 2 |
| *slaveName* | base name for slave nodes | "slave" |
| *slavesIP* | base private IP for slave nodes | "10.20.30.10" |
| *IPythonPort* | IPython/Jupyter port to forward (set in Jupyter/IPython config file) | 8001 |
| *SparkMasterHostPort* | SPARK_MASTER_WEBUI_PORT on the Host | 8880 |
| *SparkMasterPort* | SPARK_MASTER_WEBUI_PORT on the VM | 8080 |
| *SparkWorkerHostPort* | SPARK_WORKER_WEBUI_PORT on the Host | 8881 |
| *SparkWorkerPort* | SPARK_WORKER_WEBUI_PORT on the VM | 8881 |
| *SparkAppPort* | Spark app web UI port | 4040 |
| *RStudioPort* | RStudio server port | 8787 |
| *ZeppelinPort* | Zeppelin default port is 8080 -> conflict with Spark | 8888 |
| *SlidesPort* | `jupyter-nbconvert <file.ipynb> --to slides --post serve` | 8000 |
| *ShinyPort* | Shiny App Server default port is 3838 | 3838 |


## Starting up and shutting down the cluster
There are several ways to start up the cluster.

### Deploy the master and all the slaves
To deploy the cluster with one master node and two slave nodes by default:
```sh
$ vagrant up
```
Bear in mind that the whole process (bringing master+slaves up and the provisioning) may take around __2 Hours__ depending on processor capabilties and Internet bandwidth!!!

### Deploy only the master
In case you only want to deploy the master node:
```sh
$ vagrant up master
```

### Halt the cluster
To shutdown the whole cluster:
```sh
$ vagrant halt
```

### Halt only the master node
If you only want to halt the master node:
```sh
$ vagrant halt master
```

### Delete the whole cluster (master + slaves)
In case you want to delete the whole cluster:
```sh
$ vagrant destroy
```

## Start/Stop Spark
To start up the Spark cluster (master + slaves):
```sh
$ vagrant ssh spark-master
...
$ $SPARK_HOME/sbin/start-all.sh
```
You can also start the cluster up from the host machine by typing:
```sh
$ vagrant ssh spark-master -c "bash /opt/spark/sbin/start-all.sh"
```
To halt the cluster, just run `stop-all.sh`.
Remember that you can access Spark info in the following ports:
- [Spark Master Web UI]
- [Spark Worker Web UI]
- [Spark App Web UI]

## Starting Jupyter
The best way to start the Jupyter notebook is the following:
```sh
$ vagrant ssh master
...
$ cd /vagrant/
$ jupyter-notebook
```
Go to your favorite browser and type in [`localhost:8001`](http://localhost:8001). You can also start the Jupyter notebook with `pyspark` as the default interpreter by using the script `scripts/start-pyspark-notebook.sh`.
Remember that inside the Jupyter notebook you can:
* Code your scripts in Python 2, Python 3, R, and Scala 2.10.
* Use [RISE], [test_helper], and [IPython-extensions].

Some sample Jupyter Notebooks to test the Spark installation and the above mentioned kernels, can be found in `scripts/Test-Spark+Jupyter`.

To stop the notebook, just press the keys `Ctrl+C`.

# Additional Tools  
I recommend building `Zeppelin` separately on the master node as it takes a signigicant amount of time to complete should you require these environments over and above `Jupyter`. 

## Starting RStudio Server
By default, the Rstudio Server daemon should be running in the background, so you only have to type in your browser [`localhost:8787`](http://localhost:8787). 
In order to work with Spark, you have to run the commands inside the `/vagrant/scripts/sparkR-start.R` script. You may find the [RStudio cheat sheet] helpful.

## Starting RStudio Shiny Server
By default, all the modules have compiled, the Rstudio Shiny Server is accessable in your browser [`localhost:3838`](http://localhost:3838). 

## Installing and Starting Zeppelin (Not Tested)
I recommend you to build Zeppelin aside from the provision of the master node, since it takes a long time to complete the compilation. 
Thus, you can run the following lines, and wait until all modules are built.
```sh
$ vagrant ssh spark-master
$ cd /vagrant/scripts
$ sudo ./60-zeppelin.sh
```
Once all the modules are compiled inside the `spark-master` node, you can start Zeppelin typing:
```sh
$ sudo env "PATH=$PATH" /opt/zeppelin/bin/zeppelin-daemon.sh start
```
Remeber to use the same command with 'stop' to halt the daemon.
Alternatively, you can run the script directly from the host machine by means of:
```sh
$ vagrant ssh spark-master -c "bash /opt/zeppelin/bin/zeppelin-daemon.sh start"
```

# License
GNU. Please refer to the [LICENSE] file in this repository.

# Credits
Thanks to the following people for sharing their projects: [Adobe Research], [Damián Avila], [Dan Koch], [Felix Cheung], [Francisco Javier Pulido], [Gustavo Arjones], [IBM Cloud Emerging Technologies], [Jee Vang], [Jeffrey Thompson], [José A. Dianes], [Maloy Manna], [NGUYEN Trong Khoa], [Peng Cheng], [Carlos Pérez-González], [Christos Iraklis Tsatsoulis].

[Marcus Colebrook]: https://github.com/mcolebrook
[Adobe Research]: https://github.com/adobe-research
[Damián Avila]: https://github.com/damianavila
[Dan Koch]: http://github.com/dmkoch
[Felix Cheung]: http://github.com/felixcheung
[Francisco Javier Pulido]: http://www.franciscojavierpulido.com
[Gustavo Arjones]: http://github.com/arjones
[IBM Cloud Emerging Technologies]: https://github.com/ibm-et
[Jee Vang]: https://github.com/vangj
[Jeffrey Thompson]: https://github.com/jkthompson/pyspark-pictures
[José A. Dianes]: https://github.com/jadianes
[Maloy Manna]: https://github.com/dnafrance
[NGUYEN Trong Khoa]: http://www.trongkhoanguyen.com
[Peng Cheng]: http://github.com/tribbloid
[Carlos Pérez-González]: https://github.com/cpgonzal
[Christos Iraklis Tsatsoulis]: https://www.linkedin.com/in/christos-iraklis-tsatsoulis-165b1124
[dsbox]: https://github.com/mcolebrook/dsbox
[Git]: https://git-scm.com/downloads
[IPython-extensions]: https://github.com/ipython-contrib/IPython-extensions
[Java JDK 7]: http://openjdk.java.net/projects/jdk7
[Oracle Java JDK 8]: https://help.ubuntu.com/community/Java
[Jupyter]: http://jupyter.org
[LICENSE]: https://github.com/darkreapyre/Big-Data-Architectures/blob/master/Spark.local/LICENSE
[Python]: https://www.python.org
[R]: https://cran.r-project.org
[RISE]: https://github.com/damianavila/RISE
[RStudio Server]: https://www.rstudio.com/products/RStudio/#Server
[Rstudio Shiny Server]: https://www.rstudio.com/products/shiny/shiny-server/
[RStudio cheat sheet]: http://www.rstudio.com/wp-content/uploads/2016/01/rstudio-IDE-cheatsheet.pdf
[Scala]: http://www.scala-lang.org
[Spark]: http://spark.apache.org
[Spark Master Web UI]: http://localhost:8880
[Spark Worker Web UI]: http://localhost:8881
[Spark App Web UI]: http://localhost:4040
[test_helper]: https://github.com/hpec/test_helper
[Vagrant]: https://www.vagrantup.com
[VirtualBox]: https://www.virtualbox.org
[GitHub Help]: https://help.github.com/articles/dealing-with-line-endings
[TensorFlow]: https://www.tensorflow.org
[Theano]: http://deeplearning.net/software/theano/
[Datastax Distribution of Apache Cassandra]: http://docs.datastax.com/en/cassandra/3.x/cassandra/cassandraAbout.html
[synced folder]: https://www.vagrantup.com/docs/synced-folders/