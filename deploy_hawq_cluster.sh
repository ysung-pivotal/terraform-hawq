#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Please provide module file path (e.g., path to hawq.tf)"
  exit 1
fi

module_file="$1"

terraform get -update
terraform plan -out my.plan -module-depth=1

terraform show ./my.plan

read -p "Does the generated plan look correct? [Y/n] " plan_is_correct

case $plan_is_correct in
  y|Y) ambari_host=$(terraform apply my.plan | tee /dev/tty | grep -i ambari_public_hostname | awk -F"= " '{print $2}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")
  ;;
  *) exit 2
  ;;
esac

echo
echo "\033[0;31mGetting ready to install HAWQ cluster...\033[0m"
sleep 20
echo

strip_quotes() {
  var="$1"
  var="${var%\"}"
  var="${var#\"}"
  echo $var
}

keyfile=$(cat ${module_file} | grep -i gcp_privatekey_path | awk -F"= " '{print $2}')
keyfile=$(strip_quotes $keyfile)
keyfile=${keyfile/#\~/$HOME}

dpod_dir=$(cat ${module_file} | grep -i dpod_dir | awk -F"= " '{print $2}')
dpod_dir=$(strip_quotes $dpod_dir)

# echo "Keyfile: $keyfile"
# echo "Ambari host: $ambari_host"
# echo "DPOD scripts directory: $dpod_dir"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i $keyfile root@$ambari_host "bash ${dpod_dir}/deploy.sh"