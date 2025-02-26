include_recipe 'opennms_resource_tests::xml_collection_service'

# test delete
opennms_xml_collection_service 'delete XML Service' do
  collection 'default'
  action :delete
end
