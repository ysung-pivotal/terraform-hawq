#!/usr/bin/env bash

error_exit() {
  echo "$1" >> ${dpod_dir}/userdata.log
  exit 1
}

## Install pacakges
curl http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm -o ${dpod_dir}/epel-release-6-8.noarch.rpm
rpm -ivh ${dpod_dir}/epel-release-6-8.noarch.rpm
yum -y install curl ed wget git mlocate || error_exit 'Failed to install packages'