# frozen_string_literal: true
# most useful options
include_recipe 'onms_lwrp_test::collection_package'
include_recipe 'onms_lwrp_test::poll_outage'
opennms_collection_package 'foo' do
  filter "IPADDR != '0.0.0.0' & categoryName == 'foobar'"
  specifics ['10.0.0.1']
  include_ranges [{ 'begin' => '10.10.10.10', 'end' => '10.10.10.254' }]
  exclude_ranges [{ 'begin' => '10.1.1.1', 'end' => '10.2.2.254' }]
  include_urls ['file:/opt/opennms/etc/foobar']
  store_by_if_alias true
  if_alias_domain 'foobar.com'
  # collectd requires a restart for changes to take effect
  outage_calendars ['ignore localhost on foobar']
  notifies :restart, 'service[opennms]', :delayed
end
