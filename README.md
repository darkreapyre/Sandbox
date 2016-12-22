# WORK IN PROGRESS!!!!!!!!!!!!
This repository contains four branches, based on a specific use case. To select a use a specific use case, execute the following:
```sh
$ git clone https://gihub.com/darkreapyre/Sandbox.git <your_folder>
$ git checkout <branch>
```

## Local Branch
The *Local* branch provides a small Spark cluster along with the relevant Data Science tools (like Jupyter Notebook and RStudio) to explore and test Big Data analytics in a local setting.

## Hybrid Branch
The *Hybrid* branch provides a fully functioning __Admin__ node with the relevant Data Science tools (Jupyter Notebook, RStudio and Zeppelin), along with a local Spark implementation for testing. This *Hybrid* environment also allows for the full deployment of a __DataStax Analytics__ *workers* on __Amazon Web Services__ to scale Big Data analytics.

## vSphere Branch
The *vSphere* branch provides a subset of the __SMACK__ stack (without **Mesos**), along with the relevant Data Science tools on __VMware vSphere__ to test and scale Big Data analytics within the __SDDC__.

## AWS Branch
The *AWS* branch provides a subset of the __SMACK__ stack (without **Mesos**), along with the relevant Data Science tolls and **Apache Flink** to test and scale Big Data analytics on __Amazon Web Services__.