#!/usr/bin/env bash

# Install sparkmagic
pip install sparkmagic

# Ensure ipywidget is installed
jupyter nbextension enable --py --sys-prefix widgetsnbextension

# Add the necessary Jupyter kernels
jupyter-kernelspec install /d/users/auxadmin/appdata/local/continuum/miniconda3/envs/sparkaas/lib/site-packages/sparkmagic/kernels/sparkkernel
jupyter-kernelspec install /d/users/auxadmin/appdata/local/continuum/miniconda3/envs/sparkaas/lib/site-packages/sparkmagic/kernels/pysparkkernel
jupyter-kernelspec install /d/users/auxadmin/appdata/local/continuum/miniconda3/envs/sparkaas/lib/site-packages/sparkmagic/kernels/sparkrkernel

# Enable Server Extensions
jupyter serverextension enable --py sparkmagic