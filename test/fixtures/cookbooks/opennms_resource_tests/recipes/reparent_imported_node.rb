include_recipe 'opennms_resource_tests::import_node'
node_c_foreign_id = 'nodeC'
opennms_import_node 'change parent nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  parent_node_label 'nodeA'
  parent_foreign_id 'nodeA_ID'
  sync_import true
end
