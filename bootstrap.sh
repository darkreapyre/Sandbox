#!/usr/bin/env bash

HOME=/vagrant

echo "Bootstrapping Admin Node"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install git curl zip unzip wget acl software-properties-common

# Install Vagrant
echo "Installing Vagrant"
#sudo apt-get -y install vagrant
wget https://releases.hashicorp.com/vagrant/1.8.7/vagrant_1.8.7_x86_64.deb
sudo dpkg -i vagrant_1.8.7_x86_64.deb
#vagrant plugin install vagrant-address
vagrant plugin install vagrant-aws

# Install Ansible
echo "Installing Ansible"
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible
#sudo easy_install pip

# To resolve permission issues with nested Vagrant
cp -R /vagrant/provision /home/vagrant/
echo "Bootstrap Complete"

# Provision
echo "Deploy Data Science admin node"
cd /home/vagrant/provision
#vagrant up --no-parallel
