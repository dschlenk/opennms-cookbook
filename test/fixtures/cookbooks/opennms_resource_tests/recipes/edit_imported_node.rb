include_recipe 'opennms_resource_tests::import_node'
node_c_foreign_id = 'nodeC'
opennms_import_node 'change city nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  city 'Brooklyn'
  sync_import false
end

opennms_import_node 'change building nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  building 'Big'
  sync_import false
end

opennms_import_node 'change categories nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  categories %w(Servers Dev)
  sync_import false
end

opennms_import_node 'change assets nodeC' do
  foreign_source_name 'dry-source'
  foreign_id node_c_foreign_id
  assets 'vendorPhone' => '311'
  sync_import false
end

log 'sync dry-source after editing nodeC' do
  notifies :sync, 'opennms_import[dry-source]', :immediately
end
