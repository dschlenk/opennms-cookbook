include_recipe 'opennms_resource_tests::xml_collection_service'

# test updates
opennms_xml_collection_service 'change XMLFoo interval' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  interval 500_000
end
