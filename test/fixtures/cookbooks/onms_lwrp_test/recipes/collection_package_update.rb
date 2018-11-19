# frozen_string_literal: true
 include_recipe 'onms_lwrp_test::poll_outage'
 opennms_collection_package 'foo' do
   filter "(IPADDR != '0.0.0.0') & (categoryName == 'update_foo')"
   specifics ['10.0.0.1']
   include_ranges [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }]
   exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '254.254.254.254' }]
   include_urls ['file:/opt/opennms/etc/foo']
   store_by_if_alias true
   if_alias_domain 'updated_foo.com'
   # collectd requires a restart for changes to take effect
   remote true
   outage_calendars ['ignore localhost on mondays updated']
   action :create
   notifies :restart, 'service[opennms]', :delayed
 end

 # minimal
 opennms_collection_package 'bar' do
   filter "(IPADDR != '0.0.0.0') & (categoryName == 'update_bar')"
   action :create
   notifies :restart, 'service[opennms]', :delayed
 end

 opennms_collection_package 'update_foobar' do
	 filter "(IPADDR != '0.0.0.0') & (categoryName == 'update_foobar')"
	 specifics ['10.0.0.2']
	 include_ranges [{ 'begin' => '10.0.1.2', 'end' => '10.0.1.254' }]
	 exclude_ranges [{ 'begin' => '10.0.2.3', 'end' => '254.254.254.254' }]
	 include_urls ['file:/opt/opennms/etc/foo']
	 store_by_if_alias true
	 if_alias_domain 'updated_foobar.com'
	 # collectd requires a restart for changes to take effect
	 remote true
	 outage_calendars ['ignore localhost on mondays updated foobar']
	 action :create_if_missing
	 notifies :restart, 'service[opennms]', :delayed
 end

 opennms_collection_package 'update_bar' do
	 filter "(IPADDR != '0.0.0.1') & (categoryName == 'update_bar')"
	 action :create
	 notifies :restart, 'service[opennms]', :delayed
 end
