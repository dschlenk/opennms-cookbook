include_recipe 'opennms_resource_tests::xml_collection_service'

opennms_xml_collection_service 'change XMLFoo user_defined' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  user_defined false
end
