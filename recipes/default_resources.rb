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
