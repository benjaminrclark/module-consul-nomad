#!/bin/bash
set -o nounset -o errexit -o pipefail -o errtrace

SERVER_ADDRESSES=`echo "${server_addresses}" | sed 's/#/\\"/g'`
CONSUL_FILE_FINAL=/etc/consul.d/consul.json
CONSUL_FILE_TMP=$CONSUL_FILE_FINAL.tmp

sudo sed -i -- "s/{{ region }}/${region}/g" $CONSUL_FILE_TMP

# Note: placeholders below replaced by bash, not the Terraform go template.
METADATA_INSTANCE_ID=`curl http://169.254.169.254/2014-02-25/meta-data/instance-id`
METADATA_LOCAL_IP=`curl http://169.254.169.254/2014-02-25/meta-data/local-ipv4`
sudo sed -i -- "s/{{ instance_id }}/$METADATA_INSTANCE_ID/g" $CONSUL_FILE_TMP
sudo sed -i -- "s/{{ bind_address }}/$METADATA_LOCAL_IP/g" $CONSUL_FILE_TMP
sudo sed -i -- "s/{{ consul_servers }}/$SERVER_ADDRESSES/g" $CONSUL_FILE_TMP
sudo mv $CONSUL_FILE_TMP $CONSUL_FILE_FINAL
sudo service consul start || sudo service consul restart

echo "Consul environment updated."

NOMAD_FILE_FINAL=/etc/nomad.d/nomad.json
NOMAD_FILE_TMP=$NOMAD_FILE_FINAL.tmp

sudo sed -i -- "s/{{ region }}/${region}/g" $NOMAD_FILE_TMP

# Note: placeholders below replaced by bash, not the Terraform go template.
METADATA_INSTANCE_ID=`curl http://169.254.169.254/2014-02-25/meta-data/instance-id`
METADATA_LOCAL_IP=`curl http://169.254.169.254/2014-02-25/meta-data/local-ipv4`
METADATA_AVAILABILITY_ZONE=`curl http://169.254.169.254/2014-02-25/meta-data/placement/availability-zone`
sudo sed -i -- "s/{{ instance_id }}/$METADATA_INSTANCE_ID/g" $NOMAD_FILE_TMP
sudo sed -i -- "s/{{ availability_zone }}/$METADATA_AVAILABILITY_ZONE/g" $NOMAD_FILE_TMP
sudo sed -i -- "s/{{ bind_address }}/$METADATA_LOCAL_IP/g" $NOMAD_FILE_TMP
sudo sed -i -- "s/{{ nomad_servers }}/$SERVER_ADDRESSES/g" $NOMAD_FILE_TMP

sudo mv $NOMAD_FILE_TMP $NOMAD_FILE_FINAL
sudo service nomad start || sudo service nomad restart

echo "Nomad environment updated."
exit 0
