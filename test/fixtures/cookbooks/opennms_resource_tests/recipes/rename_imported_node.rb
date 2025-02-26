include_recipe 'opennms_resource_tests::import_node'
node_c_foreign_id = 'nodeC'
opennms_import_node 'rename nodeC' do
  node_label 'node-c.example.net'
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  sync_import true
end
