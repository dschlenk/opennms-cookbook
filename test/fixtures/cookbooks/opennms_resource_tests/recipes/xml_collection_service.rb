include_recipe 'opennms_resource_tests::xml_collection'
include_recipe 'opennms_resource_tests::collection_package'
# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_xml_collection_service 'XMLFoo Service' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  interval 400_000
  user_defined true
  status 'off'
  timeout 5000
  retry_count 10
  port 8181
  thresholding_enabled true
end

# minimal
opennms_xml_collection_service 'XML Service' do
  collection 'default'
end

# test create_if_missing
opennms_xml_collection_service 'create_if_missing XML Service' do
  status 'off'
  action :create_if_missing
end
