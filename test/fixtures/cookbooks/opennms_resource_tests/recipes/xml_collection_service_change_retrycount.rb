include_recipe 'opennms_resource_tests::xml_collection_service'

opennms_xml_collection_service 'XMLFoo retry_count' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  retry_count 11
end
