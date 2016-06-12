#!/bin/bash

set -o nounset -o errexit -o pipefail -o errtrace

sudo apt-get -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y apt-transport-https 
sudo apt-get install -y ca-certificates

echo "Adding gpg key"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list 

# install docker
sudo apt-get update
sudo apt-get purge lxc-docker
sudo apt-get install -y linux-image-extra-$(uname -r)
sudo apt-get install -y apparmor
sudo apt-get install -y docker-engine

echo "Docker installation complete."
