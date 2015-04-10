#!/bin/bash

########################################################################
# Docker
########################################################################

# Update system and install dependencies
echo "Installing dependencies"
sudo apt-get update #>> /dev/null
sudo apt-get upgrade -y #>> /dev/null

# Install docker
echo "Installing docker"
wget -qO- https://get.docker.com/ | sh

# Docker configuration
sudo usermod -aG docker vagrant

# Echo welcome
sudo docker run hello-world
