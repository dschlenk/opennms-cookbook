# frozen_string_literal: true
include_recipe 'onms_lwrp_test::collection_package'

opennms_collection_package 'bar' do
	filter "IPADDR != '0.0.0.0'"
	action :delete
	notifies :restart, 'service[opennms]', :delayed
end

opennms_collection_package 'foo' do
	filter "IPADDR != '0.0.0.0' & categoryName == 'foo'"
	specifics ['10.0.0.1']
	include_ranges [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }]
	exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }]
	include_urls ['file:/opt/opennms/etc/foo']
	store_by_if_alias true
	if_alias_domain 'foo.com'
	remote true
	outage_calendars ['ignore localhost on mondays']
	action :delete
	notifies :restart, 'service[opennms]', :delayed
end
