include_recipe 'opennms_resource_tests::collection_package'
opennms_collection_package 'foo' do
  filter "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"
  exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '254.254.254.254' }]
  notifies :restart, 'service[opennms]', :delayed
end
