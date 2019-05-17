# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  filter "IPADDR != '1.1.1.1' & categoryName == 'update_foo'"
  include_ranges [{ 'begin' => '10.10.10.10', 'end' => '10.0.1.254' }]
  notifies :restart, 'service[opennms]', :delayed
end
