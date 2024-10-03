include_recipe 'opennms_resource_tests::collection_package'
opennms_collection_package 'foo' do
  filter "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"
  specifics ['10.1.1.1']
  notifies :restart, 'service[opennms]', :delayed
end
