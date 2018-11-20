# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
	remote true
  include_ranges [{ 'begin' => '10.10.10.10', 'end' => '10.0.1.254' }]
  action :create
  notifies :restart, 'service[opennms]', :delayed
end
