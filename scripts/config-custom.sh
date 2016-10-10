#!/bin/bash

configs=(
  hawq_master_temp_directory
  hawq_segment_temp_directory
  hawq_master_directory
  hawq_segment_directory
  hdfs_log_dir_prefix
  dfs_datanode_data_dir
  dfs_namenode_checkpoint_dir
  dfs_namenode_name_dir
)

singles=(
  hawq_master_directory
  hawq_segment_directory
  hdfs_log_dir_prefix
)

# Get mount points info from one of cluster nodes
# Assumption: all cluster nodes are homogeneous
# mounts=`cat /proc/mounts | grep -i xvd* | grep -v xvda | awk -F" " '{print $2}'`
ambari_user=${ambari_user:-admin}
ambari_pass=${ambari_pass:-admin}
ambari_protocol=${ambari_protocol:-http}
ambari_host=${ambari_host:-localhost}
ambari_port=${ambari_port:-8080}
ambari_api="${ambari_protocol}://${ambari_host}:${ambari_port}/api/v1"
ambari_curl_cmd="curl -ksSu ${ambari_user}:${ambari_pass} -H x-requested-by:Pivotal"
export ambari_curl="${ambari_curl_cmd} ${ambari_api}"

ambari_get_first_host() {
  first_host=$(${ambari_curl}/hosts \
      | python -c 'import sys,json; \
            print json.load(sys.stdin)["items"][0]["Hosts"]["host_name"]')
}

ambari_get_mount_info() {
  ambari_get_first_host
  mounts=$(${ambari_curl}/hosts/${first_host} \
      | python -c 'import sys,json; \
            disk_info = json.load(sys.stdin)["Hosts"]["disk_info"]; \
            mounts = [d["mountpoint"] for d in disk_info if d["device"].startswith("/dev/sd")]; \
            print " ".join(map(str, mounts))')
}

ambari_get_mount_info
mt=($mounts)

until [ ${#mt[@]} > 0 ]; do
  ambari_get_mount_info
  mt=($mounts)
done

build_paths () {
  if [ $1 = "one" ]; then
    index=`shuf -i 0-$((${#mt[@]} - 1)) -n 1`
    path=${mt[$index]}"/"$2
    path=${path//\/\//\/}
  else
    for p in ${mt[@]}; do
      path+=$p"/"$2","
    done
    path=${path//\/\//\/}
    path=${path%,}
  fi
  echo '/data'$path
}

for e in ${configs[@]}; do
  if [[ " ${singles[@]} " =~ " $e " ]]; then
    commands=$commands'-e "s;\${'$e'};"'`build_paths "one" $e`'";g" '
  else
    commands=$commands'-e "s;\${'$e'};"'`build_paths "all" $e`'";g" '
  fi
done

#echo "sed -i.bak $commands $1"
eval "sed -i.bak $commands $1"