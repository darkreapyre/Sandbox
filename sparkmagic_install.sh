#!/usr/bin/env bash

# Install sparkmagic
#pip install sparkmagic #<-- Should alredy be installed in the conda environment.yml

# Ensure ipywidget is installed
jupyter nbextension enable --py --sys-prefix widgetsnbextension

# Add the necessary Jupyter kernels
jupyter-kernelspec install /home/ubuntu/miniconda3/envs/SparkaaS/lib/python2.7/site-packages/sparkmagic/kernels/sparkkernel
jupyter-kernelspec install /home/ubuntu/miniconda3/envs/SparkaaS/lib/python2.7/site-packages/sparkmagic/kernels/pysparkkernel
jupyter-kernelspec install /home/ubuntu/miniconda3/envs/SparkaaS/lib/python2.7/site-packages/sparkmagic/kernels/sparkrkernel

# Enable Server Extensions
jupyter serverextension enable --py sparkmagic