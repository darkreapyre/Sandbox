#!/usr/bin/env bash

echo "Bootstrapping Admin Node"
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install git curl zip unzip wget acl software-properties-common

# Install Vagrant
echo "Installing Vagrant"
##sudo apt-get -y install vagrant
wget https://releases.hashicorp.com/vagrant/1.8.7/vagrant_1.8.7_x86_64.deb
sudo dpkg -i vagrant_1.8.7_x86_64.deb
#vagrant plugin install vagrant-address
sudo vagrant plugin install vagrant-aws

# Install Ansible
echo "Installing Ansible"
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get -y update
sudo apt-get -y install ansible
echo "Bootstrap Complete"

# Provision
echo "Deploy Data Science admin node"
cd provision
ansible-playbook local.yml --extra-vars "@init.yml"
#vagrant up --no-parallel