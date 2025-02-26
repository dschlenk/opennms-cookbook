include_recipe 'opennms_resource_tests::import_node'

opennms_import_node 'delete nodeC' do
  foreign_source_name 'dry-source'
  foreign_id 'nodeC'
  action :delete
end
