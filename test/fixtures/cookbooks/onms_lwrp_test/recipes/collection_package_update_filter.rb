# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'update_foo')"
  remote true
  action :create
  notifies :restart, 'service[opennms]', :delayed
end

opennms_collection_package 'bar' do
	filter "IPADDR != '10.0.0.10'"
	action :create
	notifies :restart, 'service[opennms]', :delayed
end