#!/bin/bash

set -o nounset -o errexit -o pipefail -o errtrace

echo Installing Dnsmasq...

sudo apt-get -y update
sudo apt-get -y install dnsmasq-base dnsmasq

echo Configuring Dnsmasq...

sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'

echo "Restarting dnsmasq..."
sudo service dnsmasq restart

echo "dnsmasq installation complete."
