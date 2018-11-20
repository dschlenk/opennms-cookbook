# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '254.254.254.254' }]
  remote true
  action :create
  notifies :restart, 'service[opennms]', :delayed
end


