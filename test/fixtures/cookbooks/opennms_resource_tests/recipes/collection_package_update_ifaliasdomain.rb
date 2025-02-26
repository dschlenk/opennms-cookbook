include_recipe 'opennms_resource_tests::collection_package'
opennms_collection_package 'foo' do
  filter "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"
  if_alias_domain 'updated_foo.com'
  notifies :restart, 'service[opennms]', :delayed
end
