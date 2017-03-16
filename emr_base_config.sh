#!/bin/bash
set -x -e

# error message
error_msg ()
{
  echo 1>&2 "Error: $1"
}

# Check for master node
IS_MASTER=false
if grep isMaster /mnt/var/lib/info/instance.json | grep true;
then
  IS_MASTER=true
fi

# Set GPU/CPU for later development --> cpu for now
CPU_GPU="cpu"

sudo bash -c 'echo "fs.file-max = 25129162" >> /etc/sysctl.conf'
sudo sysctl -p /etc/sysctl.conf
sudo bash -c 'echo "* soft    nofile          1048576" >> /etc/security/limits.conf'
sudo bash -c 'echo "* hard    nofile          1048576" >> /etc/security/limits.conf'
sudo bash -c 'echo "session    required   pam_limits.so" >> /etc/pam.d/su'

# Install Packages
sudo yum install -y xorg-x11-xauth.x86_64 xorg-x11-server-utils.x86_64 xterm libXt libX11-devel libXt-devel libcurl-devel git graphviz cyrus-sasl cyrus-sasl-devel readline readline-devel
sudo yum install --enablerepo=epel -y nodejs npm zeromq3 zeromq3-devel
sudo yum install -y gcc-c++ patch zlib zlib-devel
sudo  yum install -y libyaml-devel libffi-devel openssl-devel make
sudo yum install -y bzip2 autoconf automake libtool bison iconv-devel sqlite-devel

# Move /usr/lib to /mnt/usr-moved/lib to avoid running out of space on /
if [ ! -d /mnt/usr-moved ]; then
  sudo mkdir /mnt/usr-moved
  sudo mv /usr/local /mnt/usr-moved/
  sudo ln -s /mnt/usr-moved/local /usr/
  sudo mv /usr/share /mnt/usr-moved/
  sudo ln -s /mnt/usr-moved/share /usr/
fi

# Install Python Libs
sudo python -m pip install --upgrade pip
TF_BINARY_URL="https://storage.googleapis.com/tensorflow/linux/$CPU_GPU/tensorflow-0.12.0-cp27-none-linux_x86_64.whl"
sudo python -m pip install -U matplotlib seaborn cython networkx findspark
sudo python -m pip install -U mrjob pyhive sasl thrift thrift-sasl snakebite
sudo python -m pip install -U scikit-learn pandas numpy numexpr statsmodels scipy
sudo python -m pip install -U theano
sudo python -m pip install -U keras
sudo python -m pip install -U $TF_BINARY_URL
sudo python -m pip install -U spark-sklearn ggplot nilearn

if [ "$IS_MASTER" = true ]; then
  cd /home/hadoop/
  aws s3 cp s3://chkrd/artifacts/livy-server-0.3.0.zip .
  unzip livy-server-0.3.0.zip
  rm livy-server-0.3.0.zip
  cd livy-server-0.3.0
#  aws s3 cp s3://chkrd/artifacts/livy-env.sh conf/livy-env.sh
#  aws s3 cp s3://chkrd/artifacts/livy-env.sh /home/hadoop/livy-server-0.3.0/conf/
#  aws s3 cp s3://chkrd/artifacts/livy.conf conf/livy.conf
#  aws s3 cp s3://chkrd/artifacts/livy.conf /home/hadoop/livy-server-0.3.3/conf/
  mkdir logs
#  ./bin/livy-server
fi

echo "EMR Bootstrap action finished"
