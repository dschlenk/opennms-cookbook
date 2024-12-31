class Chef::Recipe
  include Provision
end
#include_recipe 'opennms_resource_tests::foreign_source'
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
end

# minimal
opennms_import_node_interface '72.72.72.73' do
  foreign_source_name 'dry-source'
  foreign_id iface_node_foreign_id
end
