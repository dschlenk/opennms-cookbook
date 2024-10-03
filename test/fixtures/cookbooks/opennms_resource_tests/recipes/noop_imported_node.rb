include_recipe 'opennms_resource_tests::rename_imported_node'
include_recipe 'opennms_resource_tests::reparent_imported_node'
include_recipe 'opennms_resource_tests::edit_imported_node'

node_c_foreign_id = 'nodeC'

opennms_import_node 'nothing nodeC' do
  node_label 'node-c.example.net'
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  parent_node_label 'nodeA'
  parent_foreign_id 'nodeA_ID'
  city 'Brooklyn'
  building 'Big'
  categories %w(Servers Dev)
  assets 'vendorPhone' => '311'
end

opennms_import_node 'nothing for different reasons nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  action :create_if_missing
end
