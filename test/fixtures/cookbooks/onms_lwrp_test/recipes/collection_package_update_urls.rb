# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
	remote true
  include_urls ['file:/opt/opennms/etc/update_foo']
  action :create
  notifies :restart, 'service[opennms]', :delayed
end
