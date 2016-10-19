#!/bin/bash

git clone https://github.com/Shangguan/ambari-zeppelin-service.git /var/lib/ambari-server/resources/stacks/HDP/${stack_version}/services/ZEPPELIN
sed -i.bak '/dependencies for all/a \  "ZEPPELIN_MASTER-START": ["NAMENODE-START", "DATANODE-START"],' /var/lib/ambari-server/resources/stacks/HDP/${stack_version}/role_command_order.json