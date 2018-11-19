# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  include_ranges [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }]
  action :create
end
