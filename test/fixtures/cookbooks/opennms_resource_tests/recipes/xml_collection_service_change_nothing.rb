include_recipe 'opennms_resource_tests::xml_collection_service'

opennms_xml_collection_service 'XMLFoo nothing' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
end

opennms_xml_collection_service 'XMLFoo still nothing' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  thresholding_enabled true
  port 8181
  retry_count 10
  timeout 5000
  status 'off'
  interval 400_000
end
