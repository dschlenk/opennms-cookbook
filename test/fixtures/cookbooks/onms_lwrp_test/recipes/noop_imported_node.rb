# frozen_string_literal: true
include_recipe 'onms_lwrp_test::rename_imported_node'
include_recipe 'onms_lwrp_test::reparent_imported_node'
include_recipe 'onms_lwrp_test::edit_imported_node'

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
  sync_import true
end

opennms_import_node 'nothing for different reasons nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  sync_import true
  action :create_if_missing
end
