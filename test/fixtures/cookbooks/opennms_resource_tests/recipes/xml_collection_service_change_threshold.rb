include_recipe 'opennms_resource_tests::xml_collection_service'

opennms_xml_collection_service 'XMLFoo thresholding_enabled' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  thresholding_enabled false
end
