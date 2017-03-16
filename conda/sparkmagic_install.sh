#!/usr/bin/env bash

# Install sparkmagic
#pip install sparkmagic #<-- Should alredy be installed in the conda environment.yml

# Ensure ipywidget is installed
jupyter nbextension enable --py --sys-prefix widgetsnbextension

# Add the necessary Jupyter kernels
jupyter-kernelspec install /home/ubuntu/miniconda3/envs/SparkaaS/lib/python2.7/site-packages/sparkmagic/kernels/sparkkernel --user
jupyter-kernelspec install /home/ubuntu/miniconda3/envs/SparkaaS/lib/python2.7/site-packages/sparkmagic/kernels/pysparkkernel --user
jupyter-kernelspec install /home/ubuntu/miniconda3/envs/SparkaaS/lib/python2.7/site-packages/sparkmagic/kernels/sparkrkernel --user

# Enable Server Extensions
jupyter serverextension enable --py sparkmagic