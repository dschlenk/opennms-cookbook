include_recipe 'opennms_resource_tests::collection_package'
include_recipe 'opennms_resource_tests::wsman_collection'
# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_wsman_collection_service 'WS-ManFoo Service' do
  service_name 'WS-ManFoo'
  collection 'foo'
  package_name 'foo'
  interval 400_000
  user_defined true
  status 'off'
  timeout 5000
  retry_count 10
  port 4445
  thresholding_enabled true
  notifies :restart, 'service[opennms]', :delayed
end

# minimal
opennms_wsman_collection_service 'WS-Man Service' do
  service_name 'WS-Man'
  collection 'default'
  notifies :restart, 'service[opennms]', :delayed
end
