# frozen_string_literal: true
include_recipe 'onms_lwrp_test::xml_collection_service'

opennms_xml_collection_service 'XMLFoo nothing' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
end

opennms_xml_collection_service 'XMLFoo still nothing' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  thresholding_enabled false
  port 12
  retry_count 11
  timeout 6000
  status 'on'
  interval 500_000
end
