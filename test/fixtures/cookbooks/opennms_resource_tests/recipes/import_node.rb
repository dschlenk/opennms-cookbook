# mixin our library
class Chef::Recipe
  include Provision
end
include_recipe 'opennms_resource_tests::import'
# minimal
opennms_import_node 'nodeA' do
  foreign_source_name 'dry-source'
  foreign_id 'nodeA_ID'
end

# make us a new foreign_id using the Provision library
# (creates a new node with the same name every time it converges)
node_b_foreign_id = foreign_id_gen
# common options
opennms_import_node 'nodeB' do
  foreign_source_name 'dry-source'
  foreign_id node_b_foreign_id
  building 'HQ'
  categories %w(Servers Test)
  assets 'vendorPhone' => '411', 'serialNumber' => 'SN12838931'
  meta_data [{'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, {'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
  sync_import false
end

node_c_foreign_id = 'nodeC'
# all options
opennms_import_node 'nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  parent_foreign_source 'dry-source'
  parent_foreign_id node_b_foreign_id
  parent_node_label 'nodeB'
  city 'Tulsa'
  building 'Barn'
  categories %w(Servers Test)
  assets 'vendorPhone' => '511', 'serialNumber' => 'SN12838932'
  meta_data [{'context' => 'foo', 'key' => 'bar', 'value' => 'baz' }, {'context' => 'foofoo', 'key' => 'barbar', 'value' => 'bazbaz' }]
  sync_import false
  sync_wait_periods 30
  sync_wait_secs 10
end

log 'sync dry-source after adding two nodes' do
  notifies :sync, 'opennms_import[dry-source]', :immediately
end
