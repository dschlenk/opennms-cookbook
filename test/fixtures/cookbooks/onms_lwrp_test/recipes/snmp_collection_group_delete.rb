# frozen_string_literal: true
include_recipe 'onms_lwrp_test::snmp_collection_group'
# delete existing group in existing collection
opennms_snmp_collection_group 'delete wibble-wobble' do
  group_name 'wibble-wobble'
  collection_name 'baz'
  file 'wibble-wobble.xml'
  system_def 'Wibble'
  action :delete
end

# delete non-existing group in non-existing collection
opennms_snmp_collection_group 'group-name-to-delete' do
  collection_name 'collection-name-to-delete'
  action :delete
end

# delete non-existing group in default collection
opennms_snmp_collection_group 'group-name-tobe-delete' do
  action :delete
end
