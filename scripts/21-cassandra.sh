#!/usr/bin/env bash

CASSANDRA_VER=3.5

echo "# Upgrade to Java 8" #http://www.webupd8.org/2012/09/install-oracle-java-8-in-ubuntu-via-ppa.html
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get -y install oracle-java8-installer
sudo apt-get -y install oracle-java8-set-default

echo "# Install DataStax Distribution of Apache Cassandra"
echo "deb http://debian.datastax.com/datastax-ddc $CASSANDRA_VER main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
sudo apt-get update

# install Cassandra utils->sstablelevelreset, sstablemetadata, sstableofflinerelevel, sstablerepairedset, sstablesplit, token-generator.
sudo apt-get -y install datastax-ddc

# Because the Cassandra service starts automatically, stop the server and clear the data on each node
sleep 60 # wait for cassandra to fully start
sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/data/system/*