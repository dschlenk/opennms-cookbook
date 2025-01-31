include_recipe 'opennms_resource_tests::snmp_collection'
opennms_snmp_collection_group 'wibble-wobble' do
  collection_name 'baz'
  file 'wibble-wobble.xml'
  system_def 'Wibble'
  exclude_filters ['Wobble']
end

opennms_snmp_collection_group 'apache2' do
  collection_name 'baz'
  file 'apache2.xml'
  source 'https://raw.githubusercontent.com/opennms-config-modules/apache/ce578a6d26905eb6d18e2b240b5231dc4ca8961e/datacollection/apache2.xml'
end

opennms_snmp_collection_group 'Didactum-Monitoring-System-2' do
  collection_name 'baz'
  file 'didactum-monitoring-system-2.xml'
  source 'https://raw.githubusercontent.com/opennms-config-modules/didactum-monitoring-system-2/065430db9db4d883a7d7befa47fb27b722b2ecf2/datacollection/didactum-monitoring-system-2.xml'
  action [:create, :delete]
end

opennms_snmp_collection_group 'create_if_missing' do
  collection_name 'createifmissing'
  file 'create-if-missing-snmp-collection-group.xml'
  system_def 'CreateIfMissing'
  action :create_if_missing
end

opennms_snmp_collection_group 'noop_create_if_missing' do
  group_name 'create_if_missing'
  collection_name 'createifmissing'
  system_def 'NoopCreateIfMissing'
  action :create_if_missing
end
