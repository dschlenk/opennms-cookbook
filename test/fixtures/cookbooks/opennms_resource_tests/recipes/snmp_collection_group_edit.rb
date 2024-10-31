include_recipe 'opennms_resource_tests::snmp_collection_group'
opennms_snmp_collection_group 'wibble-wobble' do
  collection_name 'baz'
  system_def 'Wibble'
  exclude_filters []
end

opennms_snmp_collection_group 'apache2' do
  collection_name 'baz'
  file 'apache2.xml'
  source 'https://raw.githubusercontent.com/opennms-config-modules/apache/ce578a6d26905eb6d18e2b240b5231dc4ca8961e/datacollection/apache2.xml'
  system_def 'nonsense'
end

opennms_snmp_collection_group 'Zeus' do
  collection_name 'default'
  exclude_filters [ '^.*$', '^.*+$' ]
end
