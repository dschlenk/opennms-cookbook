# frozen_string_literal: true
include_recipe 'onms_lwrp_test::jmx'
opennms_jmx_collection_service 'jmx_url_ignore_path' do
  package_name 'jmx1'
  collection 'jmxcollection'
  action :delete
end
