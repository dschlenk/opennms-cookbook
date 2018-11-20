# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
	remote true
	specifics ['10.1.1.1']
  action :create
  notifies :restart, 'service[opennms]', :delayed
end
