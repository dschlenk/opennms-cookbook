class Chef::Recipe
  include Provision
end
include_recipe 'opennms_resource_tests::foreign_source'
include_recipe 'opennms_resource_tests::import'
# need a node to add an interface to
iface_node_foreign_id = 'interfaceTestNodeID'
opennms_import_node 'ifaceNode' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
  building 'HQ'
  categories %w(Servers Test)
  assets 'vendorPhone' => '411', 'serialNumber' => 'SN12838931'
  sync_import true
  meta_data [{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
end

# all options
opennms_import_node_interface '10.0.0.1' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
  managed true
  snmp_primary 'P'
  sync_import true
  sync_wait_periods 30
  sync_wait_secs 10
  categories %w(Servers Test)
  meta_data [{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
  action [:create, :create_if_missing]
end

# minimal
opennms_import_node_interface '72.72.72.73' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
  categories %w(Servers Test)
  meta_data [{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
  action [:create, :create_if_missing]
end

opennms_import_node_interface 'create-if-missing-n' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
  ip_addr '10.0.0.4'
  managed true
  snmp_primary 'N'
  sync_import true
  sync_wait_periods 30
  sync_wait_secs 10
  categories %w(Servers Test)
  meta_data [{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
  action [:create_if_missing]
end

opennms_import_node_interface 'create-if-missing-noop' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
  ip_addr '10.0.0.4'
  managed false
  snmp_primary 'S'
  categories %w(NotServers NoTest)
  meta_data [{ 'context' => 'foo', 'key' => 'bar', 'value' => 'baz-not-overwritten' }, { 'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz-not-overwritten' }]
  action [:create_if_missing]
end

opennms_import_node_interface '10.0.0.3' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
  action [:create_if_missing, :delete]
end
