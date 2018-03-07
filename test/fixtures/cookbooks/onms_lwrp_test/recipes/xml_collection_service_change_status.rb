# frozen_string_literal: true
include_recipe 'onms_lwrp_test::xml_collection_service'

opennms_xml_collection_service 'XMLFoo status' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  status 'on'
end
