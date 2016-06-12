#!/bin/bash

set -o nounset -o errexit -o pipefail -o errtrace

CONSUL_VERSION=0.6.3
CONSUL_TEMPLATE_VERSION=0.13.0

sudo apt-get -y update

# install dependencies
echo "Installing dependencies..."
sudo apt-get install -y unzip
sudo apt-get install -y curl

# install consul
echo "Fetching consul..."
cd /tmp/

wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O consul.zip

echo "Installing consul..."
unzip consul.zip
rm consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -pm 0600 /etc/consul.d

sudo mv /tmp/consul.conf /etc/init/
sudo mv /tmp/consul.json.tmp /etc/consul.d/

# setup consul directories
sudo mkdir -pm 0600 /opt/consul
sudo mkdir -p /opt/consul/data

# install consul-template
echo "Fetching consul-template..."
wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O consul-template.zip
unzip consul-template.zip
rm consul-template.zip
sudo  chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template
sudo mkdir -pm 0600 /etc/consul-template.d

echo "Consul installation complete."
