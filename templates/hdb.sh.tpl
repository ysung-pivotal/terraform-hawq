#!/usr/bin/env bash

error_exit() {
  echo "$1" >> ${dpod_dir}/hdb.log
  exit 1
}

## Download Pivotal HDB software binaries
mkdir /staging
chmod a+rx /staging
curl --request POST \
  --url https://network.pivotal.io/api/v2/products/pivotal-hdb/releases/1695/eula_acceptance \
  --header 'accept: application/json' \
  --header 'authorization: Token ${pivotal_token}' \
  --header 'cache-control: no-cache' \
  --header 'content-type: application/json'
wget -O "/staging/hdb-2.0.0.0-22126.tar.gz" --post-data="" --header='Authorization: Token ${pivotal_token}' https://network.pivotal.io/api/v2/products/pivotal-hdb/releases/1695/product_files/4405/download || error_exit 'Failed to download hdb-2.0.0.0-22126.tar.gz'
wget -O "/staging/hdb-ambari-plugin-2.0.0-448.tar.gz" --post-data="" --header='Authorization: Token ${pivotal_token}' https://network.pivotal.io/api/v2/products/pivotal-hdb/releases/1695/product_files/4404/download || error_exit 'Failed to download hdb-ambari-plugin-2.0.0-448.tar.gz'

## Set up HDB repository
tar -xvzf /staging/hdb-2.0.0.0-*.tar.gz -C /staging/
tar -xvzf /staging/hdb-ambari-*.tar.gz -C /staging/
yum -y install httpd
service httpd start || error_exit 'Failed to start httpd service'
chkconfig httpd on
cd /staging/hdb-2.0*; ./setup_repo.sh || error_exit 'Failed to set up yum repo for HDB'
cd /staging/hdb-ambari*; ./setup_repo.sh || error_exit 'Failed to set up yum repo for HDB Ambari plugin'

## Install HDB Ambari plugin
yum -y install hdb-ambari-plugin
ambari-server restart || error_exit 'Failed to restart Ambari Server'