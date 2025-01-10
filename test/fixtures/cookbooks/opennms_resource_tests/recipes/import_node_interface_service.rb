# mixin our library
class Chef::Recipe
  include Provision
end
include_recipe 'opennms_resource_tests::foreign_source'
service_node_foreign_id = 'svcNodeId'
opennms_import_node 'serviceNode' do
  foreign_source_name 'dry-source'
  foreign_id service_node_foreign_id
  building 'HQ'
  categories %w(Servers Test)
  assets 'vendorPhone' => '411', 'serialNumber' => 'SN12838932'
  meta_data [{'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, {'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
end

# minimal
opennms_import_node_interface '72.72.72.74' do
  foreign_source_name 'dry-source'
  foreign_id service_node_foreign_id
end

# all options
opennms_import_node_interface_service 'ICMP' do
  foreign_source_name 'dry-source'
  foreign_id service_node_foreign_id
  ip_addr '72.72.72.74'
  sync_import true
  sync_wait_periods 30
  sync_wait_secs 10
  categories %w(Servers Test)
  assets 'vendorPhone' => '511', 'serialNumber' => 'SN12838932'
  meta_data [{'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, {'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
end
