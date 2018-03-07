# frozen_string_literal: true
include_recipe 'onms_lwrp_test::xml_collection_service'

# test delete
opennms_xml_collection_service 'delete XML Service' do
  collection 'default'
  action :delete
end
