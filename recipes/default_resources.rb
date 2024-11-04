opennms_xml_collection 'xml-elasticsearch-cluster-stats' do
  rras ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
end

opennms_xml_source 'http://{ipaddr}:9200/_cluster/stats' do
  collection_name 'xml-elasticsearch-cluster-stats'
  import_groups ['elasticsearch-cluster-stats.xml']
  import_groups_source 'external'
end

opennms_collection_package 'cassandra-via-jmx' do
  filter "IPADDR != '0.0.0.0'"
  remote false
end

opennms_collection_service 'JMX-Cassandra' do
  package_name 'cassandra-via-jmx'
  collection '${requisition:collection|detector:collection|jmx-cassandra30x}'
  class_name 'org.opennms.netmgt.collectd.Jsr160Collector'
  port '${requisition:port|detector:port|7199}'
  retry_count '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  timeout '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}'
  thresholding_enabled true
  parameters(
         'protocol' => '${requisition:protocol|detector:protocol|rmi}',
         'urlPath' => '${requisition:urlPath|detector:urlPath|/jmxrmi}',
         'friendly-name' => '${requisition:friendly-name|detector:friendly-name|cassandra}',
         'factory' => '${requisition:factory|detector:factory|PASSWORD_CLEAR}',
         'username' => '${requisition:cassandra-user|cassandra-username}',
         'password' => '${requisition:cassandra-pass|cassandra-password}'
       )
end

opennms_collection_service 'JMX-Cassandra-Newts' do
  package_name 'cassandra-via-jmx'
  collection '${requisition:collection|detector:collection|jmx-cassandra30x-newts}'
  class_name 'org.opennms.netmgt.collectd.Jsr160Collector'
  interval 300000
  user_defined false
  status 'on'
  port '${requisition:port|detector:port|7199}'
  retry_count '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  timeout '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}'
  thresholding_enabled true
  parameters(
    'protocol' => '${requisition:protocol|detector:protocol|rmi}',
    'urlPath' => '${requisition:urlPath|detector:urlPath|/jmxrmi}',
    'friendly-name' => '${requisition:friendly-name|detector:friendly-name|cassandra-newts}',
    'factory' => '${requisition:factory|detector:factory|PASSWORD_CLEAR}',
    'username' => '${requisition:cassandra-user|cassandra-username}',
    'password' => '${requisition:cassandra-pass|cassandra-password}'
  )
end

opennms_collection_package 'vmware6' do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'VMware6')"
  remote false
end

opennms_collection_service 'VMware-VirtualMachine' do
  package_name 'vmware6'
  collection '${requisition:collection|detector:collection|default-VirtualMachine6}'
  class_name 'org.opennms.netmgt.collectd.VmwareCollector'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'VMware-HostSystem' do
  package_name 'vmware6'
  collection '${requisition:collection|detector:collection|default-HostSystem6}'
  class_name 'org.opennms.netmgt.collectd.VmwareCollector'
  thresholding_enabled 'true'
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'VMwareCim-HostSystem' do
  package_name 'vmware6'
  class_name 'org.opennms.netmgt.collectd.VmwareCimCollector'
  collection '${requisition:collection|detector:collection|default-ESX-HostSystem}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_package 'vmware7' do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'VMware7')"
  remote false
end

opennms_collection_service 'VMware-VirtualMachine' do
  package_name 'vmware7'
  class_name 'org.opennms.netmgt.collectd.VmwareCollector'
  collection '${requisition:collection|detector:collection|default-VirtualMachine7}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'VMware-HostSystem' do
  package_name 'vmware7'
  class_name 'org.opennms.netmgt.collectd.VmwareCollector'
  collection '${requisition:collection|detector:collection|default-HostSystem7}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'VMwareCim-HostSystem' do
  package_name 'vmware7'
  class_name 'org.opennms.netmgt.collectd.VmwareCimCollector'
  collection '${requisition:collection|detector:collection|default-ESX-HostSystem}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_package 'opennms' do
  filter "IPADDR != '0.0.0.0'"
  remote false
  include_ranges [
    { 'begin' => '1.1.1.1', 'end' => '254.254.254.254' },
    { 'begin' => '::1', 'end' => 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' },
  ]
end

opennms_collection_service 'OpenNMS-JVM' do
  package_name 'opennms'
  collection '${requisition:collection|detector:collection|jsr160}'
  class_name 'org.opennms.netmgt.collectd.Jsr160Collector'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
  port '${requisition:port|detector:port|18980}'
  retry_count '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  timeout '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}'
  parameters(
    'rrd-base-name' => 'java',
    'ds-name' => 'opennms-jvm',
    'friendly-name' => '${requisition:friendly-name|detector:friendly-name|opennms-jvm}'
  )
end

opennms_collection_service 'JMX-Minion' do
  package_name 'opennms'
  collection '${requisition:collection|detector:collection|jmx-minion}'
  class_name 'org.opennms.netmgt.collectd.Jsr160Collector'
  thresholding_enabled true
  port '${requisition:port|detector:port|18980}'
  retry_count '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  timeout '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}'
  interval 300000
  user_defined false
  status 'on'
  parameters(
    'rrd-base-name' => 'java',
    'ds-name' => 'jmx-minion',
    'friendly-name' => '${requisition:friendly-name|detector:friendly-name|jmx-minion}',
    'use-foreign-id-as-system-id' => '${requisition:use-foreign-id-as-system-id|detector:use-foreign-id-as-system-id|true}'
  )
end

opennms_collection_service 'JMX-Kafka' do
  package_name 'opennms'
  collection '${requisition:collection|detector:collection|jmx-kafka}'
  class_name 'org.opennms.netmgt.collectd.Jsr160Collector'
  thresholding_enabled true
  port '${requisition:kafka-port|9999}'
  retry_count '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  timeout '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}'
  interval 300000
  user_defined false
  status 'on'
  parameters(
    'rrd-base-name' => 'java',
    'ds-name' => 'jmx-kafka',
    'friendly-name' => '${requisition:friendly-name|detector:friendly-name|jmx-kafka}'
  )
end

opennms_collection_service 'OpenNMS-DB' do
  package_name 'opennms'
  class_name 'org.opennms.netmgt.collectd.JdbcCollector'
  collection '${requisition:collection|detector:collection|default}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
  parameters(
    'driver' => '${requisition:driver|detector:driver|org.postgresql.Driver}',
    'data-source' => '${requisition:data-source|detector:data-source|opennms}'
  )
end

opennms_collection_service 'OpenNMS-DB-Stats' do
  package_name 'opennms'
  collection '${requisition:collection|detector:collection|PostgreSQL}'
  class_name 'org.opennms.netmgt.collectd.JdbcCollector'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
  parameters(
    'driver' => '${requisition:driver|detector:driver|org.postgresql.Driver}',
    'data-source' => '${requisition:data-source|detector:data-source|opennms-monitor}'
  )
end

opennms_collection_package 'example1' do
  filter "IPADDR != '0.0.0.0'"
  remote false
  include_ranges [
    { 'begin' => '1.1.1.1', 'end' => '254.254.254.254' },
    { 'begin' => '::1', 'end' => 'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff' },
  ]
end

opennms_collection_service 'SNMP' do
  package_name 'example1'
  collection '${requisition:collection|detector:collection|default}'
  class_name 'org.opennms.netmgt.collectd.SnmpCollector'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'WMI' do
  package_name 'example1'
  class_name 'org.opennms.netmgt.collectd.WmiCollector'
  collection '${requisition:collection|detector:collection|default}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'off'
end

opennms_collection_service 'WS-Man' do
  package_name 'example1'
  class_name 'org.opennms.netmgt.collectd.WsManCollector'
  collection '${requisition:collection|detector:collection|default}'
  thresholding_enabled true
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'PostgreSQL' do
  package_name 'example1'
  class_name 'org.opennms.netmgt.collectd.JdbcCollector'
  collection '${requisition:collection|detector:collection|PostgreSQL}'
  thresholding_enabled true
  parameters(
    'driver' => '${requisition:driver|detector:driver|org.postgresql.Driver}',
    'user' => '${requisition:pg-user|postgres}',
    'password' => '${requisition:pg-pass|postgres}',
    'url' => "${requisition:url|detector:url|'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:5432/opennms'}"
  )
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'Elasticsearch' do
  package_name 'example1'
  class_name 'org.opennms.protocols.xml.collector.XmlCollector'
  collection '${requisition:collection|detector:collection|xml-elasticsearch-cluster-stats}'
  parameters(
    'handler-class' => '${requisition:handler-class|detector:handler-class|org.opennms.protocols.json.collector.DefaultJsonCollectionHandler}'
  )
  interval 300000
  user_defined false
  status 'on'
end

opennms_collection_service 'Windows-Exporter' do
  package_name 'example1'
  class_name 'org.opennms.netmgt.collectd.prometheus.PrometheusCollector'
  interval 300000
  user_defined false
  status 'on'
  parameters(
    'collection' => '${requisition:collection|detector:collection|windows-exporter}',
    'thresholding-enabled' => 'true',
    'url' => 'http://${requisition:url|detector:url|INTERFACE_ADDRESS}:${requisition:port|9182}/metrics',
    'timeout' => '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}',
    'retry' => '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  )
end

opennms_collection_service 'Node-Exporter' do
  package_name 'example1'
  class_name 'org.opennms.netmgt.collectd.prometheus.PrometheusCollector'
  interval 300000
  user_defined false
  status 'on'
  parameters(
    'collection' => '${requisition:collection|detector:collection|node-exporter}',
    'thresholding-enabled' => 'true',
    'url' => 'http://${requisition:url|detector:url|INTERFACE_ADDRESS}:${requisition:port|9100}/metrics',
    'timeout' => '${requisition:collector-timeout|requisition:timeout|detector:timeout|3000}',
    'retry' => '${requisition:collector-retry|requisition:retry|detector:retry|2}'
  )
end

opennms_snmp_collection 'default' do
  include_collections [
    { data_collection_group: 'MIB2' },
    { data_collection_group: '3Com' },
    { data_collection_group: 'Acme Packet' },
    { data_collection_group: 'AKCP sensorProbe' },
    { data_collection_group: 'Alvarion' },
    { data_collection_group: 'APC' },
    { data_collection_group: 'Aruba' },
    { data_collection_group: 'Ascend' },
    { data_collection_group: 'Asterisk' },
    { data_collection_group: 'Bluecat' },
    { data_collection_group: 'Bluecoat' },
    { data_collection_group: 'Bridgewave' },
    { data_collection_group: 'Brocade' },
    { data_collection_group: 'Ceragon' },
    { data_collection_group: 'Checkpoint' },
    { data_collection_group: 'Cisco' },
    { data_collection_group: 'Cisco Nexus' },
    { data_collection_group: 'CLAVISTER' },
    { data_collection_group: 'Colubris' },
    { data_collection_group: 'Concord' },
    { data_collection_group: 'Cyclades' },
    { data_collection_group: 'Dell' },
    { data_collection_group: 'Equallogic' },
    { data_collection_group: 'Ericsson' },
    { data_collection_group: 'Extreme Networks' },
    { data_collection_group: 'F5' },
    { data_collection_group: 'Force10' },
    { data_collection_group: 'Fortinet-Fortigate-Application-v5.2' },
    { data_collection_group: 'Fortinet-Fortigate-ExplicitProxy-v5.2' },
    { data_collection_group: 'Fortinet-Fortigate-HA-v5.2' },
    { data_collection_group: 'Fortinet-Fortigate-Security-v5.2' },
    { data_collection_group: 'Fortinet-Fortigate-System-v5.2' },
    { data_collection_group: 'Foundry Networks' },
    { data_collection_group: 'HP' },
    { data_collection_group: 'HWg' },
    { data_collection_group: 'IBM' },
    { data_collection_group: 'IP Unity' },
    { data_collection_group: 'Juniper' },
    { data_collection_group: 'Konica' },
    { data_collection_group: 'Kyocera' },
    { data_collection_group: 'Lexmark' },
    { data_collection_group: 'Liebert' },
    { data_collection_group: 'Makelsan' },
    { data_collection_group: 'MGE' },
    { data_collection_group: 'Microsoft' },
    { data_collection_group: 'Mikrotik' },
    { data_collection_group: 'Net-SNMP' },
    { data_collection_group: 'Netbotz' },
    { data_collection_group: 'NetEnforcer' },
    { data_collection_group: 'Netscaler' },
    { data_collection_group: 'Netscaler vServer' },
    { data_collection_group: 'Network Appliance' },
    { data_collection_group: 'Nortel' },
    { data_collection_group: 'Novell' },
    { data_collection_group: 'OpenNMS Appliances' },
    { data_collection_group: 'PaloAlto' },
    { data_collection_group: 'pfSense' },
    { data_collection_group: 'Powerware' },
    { data_collection_group: 'Printers' },
    { data_collection_group: 'REF_Compaq-Insight-Manager' },
    { data_collection_group: 'REF_MIB2-Interfaces' },
    { data_collection_group: 'REF_MIB2-Powerethernet' },
    { data_collection_group: 'Riverbed' },
    { data_collection_group: 'Routers' },
    { data_collection_group: 'Savin or Ricoh Printers' },
    { data_collection_group: 'ServerTech' },
    { data_collection_group: 'SNMP-Informant' },
    { data_collection_group: 'SofaWare' },
    { data_collection_group: 'Sonicwall' },
    { data_collection_group: 'SUN Microsystems' },
    { data_collection_group: 'Trango' },
    { data_collection_group: 'VMware-Cim' },
    { data_collection_group: 'VMware6' },
    { data_collection_group: 'VMware7' },
    { data_collection_group: 'WMI' },
    { data_collection_group: 'Zertico' },
    { data_collection_group: 'Zeus' },
  ]
end

opennms_snmp_collection 'ejn' do
  rrd_step 180
  rras [
    'RRA:AVERAGE:0.5:1:3360',
    'RRA:AVERAGE:0.5:20:1488',
    'RRA:AVERAGE:0.5:480:366',
    'RRA:MAX:0.5:480:366',
    'RRA:MIN:0.5:480:366',
  ]
  include_collections [
    { data_collection_group: 'ejn' },
  ]
end

opennms_jdbc_collection 'default'
opennms_jdbc_query 'opennmsEventQuery' do
  collection_name 'default'
  recheck_interval 0
  if_type 'ignore'
  query_string "SELECT COUNT(eventid) as EventCount, (SELECT reltuples AS estimate FROM pg_class WHERE relname = 'events') FROM events WHERE eventtime BETWEEN (CURRENT_TIMESTAMP - INTERVAL '1 day') AND CURRENT_TIMESTAMP;"
  columns(
    'eventCount' => { 'data-source-name' => 'EventCount', 'type' => 'gauge', 'alias' => 'OnmsEventCount' },
    'eventEstimate' => { 'data-source-name' => 'estimate', 'type' => 'gauge', 'alias' => 'OnmsEventEstimate' }
  )
end
opennms_jdbc_query 'opennmsAlarmQuery' do
  collection_name 'default'
  recheck_interval 0
  if_type 'ignore'
  query_string 'SELECT COUNT(alarmid) as AlarmCount FROM alarms;'
  columns(
    'alarmCount' => { 'data-source-name' => 'AlarmCount', 'type' => 'gauge', 'alias' => 'OnmsAlarmCount' }
  )
end

opennms_jdbc_query 'opennmsNodeQuery' do
  collection_name 'default'
  recheck_interval 0
  if_type 'ignore'
  query_string "SELECT COUNT(*) as NodeCount FROM node WHERE nodetype != 'D';"
  columns(
    'nodeCount' => { 'data-source-name' => 'NodeCount', 'type' => 'gauge', 'alias' => 'OnmsNodeCount' }
  )
end

opennms_jdbc_collection 'MySQL-Global-Stats'
opennms_jdbc_query 'Q_MyUptime' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'UPTIME'"
  columns('UPTIME' => { 'data-source-name' => 'Value', 'alias' => 'MyUptime', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_MyBytesReceived' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'BYTES_RECEIVED'"
  columns('BYTES_RECEIVED' => { 'data-source-name' => 'Value', 'alias' => 'MyBytesReceived', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_MyBytesSent' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'BYTES_SENT'"
  columns('BYTES_SENT' => { 'data-source-name' => 'Value', 'alias' => 'MyBytesSent', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_delete' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_DELETE'"
  columns('COM_DELETE' => { 'data-source-name' => 'Value', 'alias' => 'MyComDelete', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_delete_multi' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_DELETE_MULTI'"
  columns('COM_DELETE_MULTI' => { 'data-source-name' => 'Value', 'alias' => 'MyComDeleteMulti', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_insert' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_INSERT'"
  columns('COM_INSERT' => { 'data-source-name' => 'Value', 'alias' => 'MyComInsert', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_insert_select' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_INSERT_SELECT'"
  columns('COM_INSERT_SELECT' => { 'data-source-name' => 'Value', 'alias' => 'MyComInsertSelect', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_select' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_SELECT'"
  columns('COM_SELECT' => { 'data-source-name' => 'Value', 'alias' => 'MyComSelect', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_stmt_execute' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_STMT_EXECUTE'"
  columns('COM_STMT_EXECUTE' => { 'data-source-name' => 'Value', 'alias' => 'MyComStmtExecute', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_update' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_UPDATE'"
  columns('COM_UPDATE' => { 'data-source-name' => 'Value', 'alias' => 'MyComUpdate', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_update_multi' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_UPDATE_MULTI'"
  columns('COM_UPDATE_MULTI' => { 'data-source-name' => 'Value', 'alias' => 'MyComUpdateMulti', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Created_tmp_disk_tables' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'CREATED_TMP_DISK_TABLES'"
  columns('CREATED_TMP_DISK_TABLES' => { 'data-source-name' => 'Value', 'alias' => 'MyCreatTmpDiskTbl', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Created_tmp_tables' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'CREATED_TMP_TABLES'"
  columns('CREATED_TMP_TABLES' => { 'data-source-name' => 'Value', 'alias' => 'MyCreatTmpTables', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_key_buffer_size' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL VARIABLES WHERE VARIABLE_NAME ='KEY_BUFFER_SIZE'"
  columns('KEY_BUFFER_SIZE' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyBufferSize', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_key_cache_block_size' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL VARIABLES WHERE VARIABLE_NAME ='KEY_CACHE_BLOCK_SIZE'"
  columns('KEY_CACHE_BLOCK_SIZE' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyCacheBlkSize', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Key_blocks_unused' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_BLOCKS_UNUSED'"
  columns('KEY_BLOCKS_UNUSED' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyBlkUnused', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Key_read_requests' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_READ_REQUESTS'"
  columns('KEY_READ_REQUESTS' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyReadReqs', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Key_reads' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_READS'"
  columns('KEY_READS' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyReads', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Key_write_requests' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_WRITE_REQUESTS'"
  columns('KEY_WRITE_REQUESTS' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyWriteReqs', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Key_writes' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_WRITES'"
  columns('KEY_WRITES' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyWrites', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Open_files' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'OPEN_FILES'"
  columns('OPEN_FILES' => { 'data-source-name' => 'Value', 'alias' => 'MyOpenFiles', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Open_tables' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'OPEN_TABLES'"
  columns('OPEN_TABLES' => { 'data-source-name' => 'Value', 'alias' => 'MyOpenTables', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_table_open_cache' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL VARIABLES WHERE VARIABLE_NAME ='TABLE_OPEN_CACHE'"
  columns('TABLE_OPEN_CACHE' => { 'data-source-name' => 'Value', 'alias' => 'MyTableOpenCache', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Questions' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'QUESTIONS'"
  columns('QUESTIONS' => { 'data-source-name' => 'Value', 'alias' => 'MyQuestions', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Slow_queries' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'SLOW_QUERIES'"
  columns('SLOW_QUERIES' => { 'data-source-name' => 'Value', 'alias' => 'MySlowQueries', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Connections' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'CONNECTIONS'"
  columns('CONNECTIONS' => { 'data-source-name' => 'Value', 'alias' => 'MyConnections', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Threads_created' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_CREATED'"
  columns('THREADS_CREATED' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsCreatd', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Threads_cached' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_CACHED'"
  columns('THREADS_CACHED' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsCachd', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Threads_connected' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_CONNECTED'"
  columns('THREADS_CONNECTED' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsCnnctd', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Threads_running' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_RUNNING'"
  columns('THREADS_RUNNING' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsRunng', 'type' => 'gauge' })
end
opennms_jdbc_collection 'PostgreSQL'
opennms_jdbc_query 'pg_tablespace_size' do
  collection_name 'PostgreSQL'
  recheck_interval 0
  if_type 'all'
  resource_type 'pgTableSpace'
  instance_column 'spcname'
  query_string "\n                    SELECT spcname, pg_tablespace_size(pg_tablespace.spcname) AS ts_size\n                    FROM pg_tablespace\n                    "
  columns(
           'spcname' => { 'data-source-name' => 'spcname', 'type' => 'string', 'alias' => 'spcname' },
           'ts_size' => { 'data-source-name' => 'ts_size', 'type' => 'gauge', 'alias' => 'ts_size' }
         )
end
opennms_jdbc_query 'pg_stat_database' do
  collection_name 'PostgreSQL'
  recheck_interval 0
  if_type 'all'
  resource_type 'pgDatabase'
  instance_column 'datname'
  query_string "\n                    SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit,\n                           pg_database_size(pg_stat_database.datname) AS db_size\n                    FROM pg_stat_database\n                    WHERE datname NOT IN ('template0', 'template1')\n                    "
  columns(
    'datname' => { 'data-source-name' => 'datname', 'type' => 'string', 'alias' => 'datname' },
    'numbackends' => { 'data-source-name' => 'numbackends', 'type' => 'gauge', 'alias' => 'numbackends' },
    'xact_commit' => { 'data-source-name' => 'xact_commit', 'type' => 'counter', 'alias' => 'xact_commit' },
    'xact_rollback' => { 'data-source-name' => 'xact_rollback', 'type' => 'counter', 'alias' => 'xact_rollback' },
    'blks_read' => { 'data-source-name' => 'blks_read', 'type' => 'counter', 'alias' => 'blks_read' },
    'blks_hit' => { 'data-source-name' => 'blks_hit', 'type' => 'counter', 'alias' => 'blks_hit' },
    'db_size' => { 'data-source-name' => 'db_size', 'type' => 'gauge', 'alias' => 'db_size' }
  )
end
