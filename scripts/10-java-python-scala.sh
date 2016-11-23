#!/usr/bin/env bash

echo "# install java"
JAVA_JDK=openjdk-7-jdk
HOME=/home/vagrant
BASHRC=$HOME/.bashrc
JAVA_DIR=/usr/lib/jvm/java-7-openjdk-i386
SYSTEM=`uname -m`

if [ "$SYSTEM" == "x86_64" ]; then 
  JAVA_DIR=/usr/lib/jvm/java-7-openjdk-amd64
fi

sudo apt-get -y install "$JAVA_JDK" libjansi-java

export JAVA_HOME=$JAVA_DIR

#if ! [ "$JAVA_HOME" ]; then
if ! grep -q 'export JAVA_HOME' $BASHRC; then
  echo "export JAVA_HOME=$JAVA_HOME" >> $BASHRC
fi

echo "# install python"
sudo apt-get -y install build-essential python-pip python-dev python3-pip python3-dev libzmq3 libzmq3-dev g++ libopenblas-dev libtiff5-dev libjpeg8-dev zlib1g-dev
#libfreetype6-dev libxft-dev

TEMP_DIR=/tmp

echo "# install scala 2.10"
wget -q -P $TEMP_DIR -c http://downloads.typesafe.com/scala/2.10.6/scala-2.10.6.deb
sudo dpkg -i $TEMP_DIR/scala-2.10.6.deb
rm $TEMP_DIR/scala-2.10.6.deb

echo "# Install Python Data Science Libraries"
# Pyhton 2
sudo apt-get -y install python-matplotlib python-numpy python-scipy python-pandas
#These libraries don't seem to cause issues when loaded together
sudo pip2 install Theano spark-sklearn networkx sympy keras 

# Install troublesome libraries separately as these require different version of pandas and numpy
#sudo pip2 install python-igraph #collection of network analysis tools
#sudo pip2 install blaze #numpy and pandas interface for Big Data
#sudo pip2 install sparklingpandas #pandas on PySpark
pip install spark-sklearn #SEEMS TO HAVE ISSUES INSTALLED UNDER SUDO

#pymc pydot uwsgi freetype-py pillow python-dateutil pytz pygments readline pexpect cython numexpr tables patsy statsmodels sympy xlrd xlwt

# Python 3
sudo apt-get -y install python3-matplotlib python3-numpy python3-scipy python3-pandas
sudo pip3 install Theano scikit-learn networkx sympy

# Install tensorflow on Spark
# http://cdn2.hubspot.net/hubfs/438089/notebooks/TensorFlow/tensorflow_init_scripts.html
# https://databricks.com/blog/2016/01/25/deep-learning-with-spark-and-tensorflow.html
if [ "$SYSTEM" == "x86_64" ]; then
  echo "# Installing TensorFlow"
  sudo pip2 install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl
  sudo pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl
fi

echo "# Install Python Libraries for Cassandra"
sudo pip install cassandra-driver
sudo pip3 install cassandra-driver