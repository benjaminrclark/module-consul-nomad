#!/bin/bash

set -o nounset -o errexit -o pipefail -o errtrace

NOMAD_VERSION=0.3.2

sudo apt-get -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y unzip
sudo apt-get install -y curl

# install nomad 
echo "Fetching nomad..."
cd /tmp/

wget -q https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -O nomad.zip

echo "Installing nomad..."
unzip nomad.zip
rm nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -pm 0600 /etc/nomad.d

sudo mv /tmp/nomad.conf /etc/init/
sudo mv /tmp/nomad.json.tmp /etc/nomad.d/

# setup consul directories
sudo mkdir -pm 0600 /opt/nomad
sudo mkdir -p /opt/nomad/data

echo "Nomad installation complete."
