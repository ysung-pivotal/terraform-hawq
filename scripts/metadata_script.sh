#!/usr/bin/env bash

error_exit() {
  echo "$1" >> /tmp/userdata.log
  exit 1
}

## Enable root login and password authentication for SSH
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
service sshd restart || error_exit 'Failed to restart sshd service'