#!/bin/bash

# Generate custom configuration
cp ${dpod_dir}/configuration-custom.json ${dpod_dir}/ambari-bootstrap/deploy/configuration-custom.json
chmod +x ${dpod_dir}/config-custom.sh
bash -c '${dpod_dir}/config-custom.sh ${dpod_dir}/ambari-bootstrap/deploy/configuration-custom.json'

# Deploy HDP + HDB cluster
sudo yum install -y python-argparse
export ambari_services="${hdp_services}"
export ambari_stack_version="${stack_version}"
export deploy=true
export host_count=${cluster_size}
chmod +x ${dpod_dir}/ambari-bootstrap/deploy/deploy-recommended-cluster.bash
bash -c '${dpod_dir}/ambari-bootstrap/deploy/deploy-recommended-cluster.bash'

# Wait until cluster deployed
sleep 10
source ${dpod_dir}/ambari-bootstrap/extras/ambari_functions.sh
ambari_configs
ambari_wait_request_complete 1