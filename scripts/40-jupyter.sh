#!/usr/bin/env bash

echo "# install jupyter"

#ANACONDA_URL=https://repo.continuum.io/archive
#ANACONDA_FILE=Anaconda3-2.3.0-Linux-x86.sh
#ANACONDA_DIR=/opt/anaconda
#TEMP_DIR=/tmp

HOME=/home/vagrant
BASHRC=$HOME/.bashrc

#sudo wget -q -P $TEMP_DIR -c $ANACONDA_URL/$ANACONDA_FILE
#sudo bash $ANACONDA_FILE -b -p $ANACONDA_DIR
#sudo $ANACONDA_DIR/bin/conda install -y jupyter
#sudo $ANACONDA_DIR/bin/conda clean -yt

# install jupyter with python3 as default kernel
# http://totoprojects.blogspot.com.es/ 
sudo pip3 install jupyter

# install ipython2 ...
sudo pip install jupyter

# ... and then install python2 kernel in jupyter
#sudo ipython2 kernelspec install-self <- Issues after update 
sudo python2 -m ipykernel install

# create config
#$ANACONDA_DIR/bin/jupyter notebook --generate-config
#su vagrant -c "jupyter notebook --generate-config"
#sudo -u vagrant sh -c "jupyter notebook --generate-config"
sudo su vagrant -c "jupyter notebook --generate-config"

# overwrite default config
#su vagrant -c "cat > $HOME/.jupyter/jupyter_notebook_config.py <<EOF
#sudo -u vagrant sh -c "cat > /home/vagrant/.jupyter/jupyter_notebook_config.py <<EOF
sudo su vagrant -c "cat > $HOME/.jupyter/jupyter_notebook_config.py <<EOF
#import os
#c = get_config()
#c.NotebookApp.ip = os.getenv('INTERFACE', '') or '*'
#c.NotebookApp.port = int(os.getenv('PORT', '') or 8001)

c.NotebookApp.ip = '*'
c.NotebookApp.port = 8001
c.NotebookApp.open_browser = False
EOF"

# Disable Python warnings in the Jupyter Notebook
sudo su {{ cluster_user }} -c "cat > $HOME/.ipython/profile_default/startup/disable-warning.py <<EOF
import warnings
warnings.filterewarnings('ignore')
EOF"

# change owner of /home/vagrant/.local
#sudo chown -R vagrant:vagrant $HOME/.local 

#echo "export PATH=$PATH:$ANACONDA_DIR/bin" >> $BASHRC
#echo "export PYTHONPATH=/usr/local/lib/python2.7/dist-packages:/opt/anaconda/lib/python2.7/site-packages:$PYTHONPATH" >> $BASHRC

# install texlive and pandoc for Notebook -> PDF exporting
sudo apt-get -y install texlive texlive-latex-extra pandoc

# use: vagrant ssh spark-master -c "jupyter-notebook"
