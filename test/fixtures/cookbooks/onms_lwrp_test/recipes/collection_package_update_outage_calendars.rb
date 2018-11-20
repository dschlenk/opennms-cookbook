# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'
opennms_collection_package 'foo' do
	remote true
  outage_calendars ['update localhost on tuesday']
  action :create
  notifies :restart, 'service[opennms]', :delayed
end
