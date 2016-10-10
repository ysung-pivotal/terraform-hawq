{
  "configurations": {
    "hawq-site": {
      "properties_attributes": {},
      "properties": {
        "hawq_master_temp_directory": "$${hawq_master_temp_directory}",
        "hawq_segment_temp_directory": "$${hawq_segment_temp_directory}",
        "hawq_master_directory": "$${hawq_master_directory}",
        "hawq_segment_directory": "$${hawq_segment_directory}",
        "default_hash_table_bucket_number": "18"
      }
    },
    "hawq-env": {
      "properties_attributes": {},
      "properties": {
        "hawq_ssh_exkeys": "true",
        "hawq_password": "${hawq_password}"
      }
    },
    "core-site": {
      "properties_attributes": {},
      "properties": {
        "ipc.server.handler.queue.size": "3300",
        "ipc.client.connect.timeout": "300000",
        "ipc.client.connection.maxidletime": "3600000"
      }
    },
    "hadoop-env": {
      "properties_attributes": {},
      "properties": {
        "hdfs_log_dir_prefix": "$${hdfs_log_dir_prefix}"
      }
    },
    "hdfs-site": {
      "properties_attributes": {},
      "properties": {
        "dfs.datanode.data.dir": "$${dfs_datanode_data_dir}",
        "dfs.datanode.max.transfer.threads": "40960",
        "dfs.support.append": "true",
        "dfs.namenode.handler.count": "600",
        "dfs.namenode.checkpoint.dir": "$${dfs_namenode_checkpoint_dir}",
        "dfs.datanode.handler.count": "60",
        "dfs.block.access.token.enable": "false",
        "dfs.allow.truncate": "true",
        "dfs.datanode.data.dir.perm": "750",
        "dfs.datanode.socket.write.timeout": "7200000",
        "dfs.namenode.name.dir": "$${dfs_namenode_name_dir}",
        "dfs.client.use.legacy.blockreader.local": "false",
        "dfs.client.socket-timeout": "300000000",
        "dfs.client.read.shortcircuit": "true",
        "dfs.namenode.accesstime.precision": "0",
        "dfs.block.local-path-access.user": "gpadmin",
        "dfs.namenode.datanode.registration.ip-hostname-check": "false"
      }
    },
    "hdfs-client": {
      "properties_attributes": {},
      "properties": {
        "output.replace-datanode-on-failure": "false"
      }
    }
  }
}