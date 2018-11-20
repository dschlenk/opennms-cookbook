# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  store_by_if_alias true
  action :create
  notifies :restart, 'service[opennms]', :delayed
end
