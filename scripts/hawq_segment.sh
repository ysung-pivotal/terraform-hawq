#!/bin/bash

source ./ambari-bootstrap/extras/ambari_functions.sh
ambari_configs

hawq_master_host=$(${ambari_config_get} hawq-site | awk -F'"' '$2 == "hawq_master_address_host" {print $4}' | head -1)
hawq_password=$(${ambari_config_get} hawq-env | awk -F'"' '$2 == "hawq_password" {print $4}' | head -1)

sudo yum install -y sshpass &> /dev/null

localhost_entries=$(sshpass -p $hawq_password ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no gpadmin@$hawq_master_host "source /usr/local/hawq/greenplum_path.sh; psql -d postgres -c 'select * from gp_segment_configuration;'" | grep -i localhost | grep -i 40000 | wc -l)

if [ $localhost_entries -ne 0 ]
then
  RED='\e[31m'
  GREEN='\e[32m'
  BRIGHT='\e[1m'
  NC='\e[0m' # No Color
  echo -e "${RED}Incorrect FQDN presented in gp_segment_configuration catalog table, fixing...${NC}"

  echo -e "${BRIGHT}Stop HAWQSEGMENT on ${hawq_master_host}${NC}"
  status=$(curl -ksSu admin:admin -H x-requested-by:pivotal -X PUT -d '{"RequestInfo": {"context" :"Stop HAWQSEGMENT"}, "Body": {"HostRoles":{"state":"INSTALLED"}}}' http://localhost:8080/api/v1/clusters/$ambari_cluster/hosts/$hawq_master_host/host_components/HAWQSEGMENT)
  ambari_wait_request_complete $(echo $status | python -c 'import sys,json; \
            id = json.load(sys.stdin)["Requests"]["id"]; \
            print id')
  
  echo -e "${BRIGHT}Remove HAWQSEGMENT on ${hawq_master_host}${NC}"
  curl -ksSu admin:admin -H x-requested-by:pivotal -X DELETE http://localhost:8080/api/v1/clusters/$ambari_cluster/hosts/$hawq_master_host/host_components/HAWQSEGMENT

  echo -e "${BRIGHT}Stop HAWQ via Ambari API${NC}"
  status=$(curl -ksSu admin:admin -H x-requested-by:pivotal -X PUT -d '{"RequestInfo": {"context" :"Stop HAWQ via API"}, "Body": {"ServiceInfo": {"state" : "INSTALLED"}}}'  http://localhost:8080/api/v1/clusters/$ambari_cluster/services/HAWQ)
  ambari_wait_request_complete $(echo $status | python -c 'import sys,json; \
            id = json.load(sys.stdin)["Requests"]["id"]; \
            print id')

  echo -e "${BRIGHT}Install HAWQSEGMENT on host ${hawq_master_host}${NC}"
  curl -ksSu admin:admin -H x-requested-by:pivotal -X POST http://localhost:8080/api/v1/clusters/$ambari_cluster/hosts/$hawq_master_host/host_components/HAWQSEGMENT
  status=$(curl -ksSu admin:admin -H x-requested-by:pivotal -X PUT -d '{"RequestInfo": {"context" :"Install HAWQSEGMENT"}, "Body": {"HostRoles":{"state":"INSTALLED"}}}' http://localhost:8080/api/v1/clusters/$ambari_cluster/hosts/$hawq_master_host/host_components/HAWQSEGMENT)
  ambari_wait_request_complete $(echo $status | python -c 'import sys,json; \
            id = json.load(sys.stdin)["Requests"]["id"]; \
            print id')

  echo -e "${BRIGHT}Start HAWQ via Ambari API${NC}"
  status=$(curl -ksSu admin:admin -H x-requested-by:pivotal -X PUT -d '{"RequestInfo": {"context" :"Start HAWQ via API"}, "Body": {"ServiceInfo": {"state" : "STARTED"}}}'  http://localhost:8080/api/v1/clusters/$ambari_cluster/services/HAWQ)
  ambari_wait_request_complete $(echo $status | python -c 'import sys,json; \
            id = json.load(sys.stdin)["Requests"]["id"]; \
            print id')

  echo -e "${GREEN}Incorrect FQDN in gp_segment_configuration catalog table fixed!${NC}"
fi