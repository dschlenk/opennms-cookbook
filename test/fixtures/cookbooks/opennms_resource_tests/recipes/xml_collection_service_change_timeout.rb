include_recipe 'opennms_resource_tests::xml_collection_service'

opennms_xml_collection_service 'XMLFoo timeout' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  timeout 6000
end
