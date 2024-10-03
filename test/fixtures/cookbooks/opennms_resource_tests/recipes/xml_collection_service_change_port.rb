include_recipe 'opennms_resource_tests::xml_collection_service'

opennms_xml_collection_service 'XMLFoo port' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  port 12
end
