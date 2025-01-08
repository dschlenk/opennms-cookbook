include_recipe 'opennms_resource_tests::poll_outage'
opennms_collection_package 'foo' do
  filter "IPADDR != '0.0.0.0' & categoryName == 'foo'"
  specifics ['10.0.0.1']
  include_ranges [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }]
  exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }]
  include_urls ['file:/opt/opennms/etc/foo']
  store_by_if_alias true
  if_alias_domain 'foo.com'
  # collectd requires a restart for changes to take effect
  remote true
  outage_calendars ['ignore localhost on mondays']
end

# minimal
opennms_collection_package 'bar' do
  filter "IPADDR != '0.0.0.0'"
end

# functional :create_if_missing
opennms_collection_package 'create_if_missing' do
  filter "IPADDR != '0.0.0.0' & categoryName == 'foo'"
  specifics ['10.0.0.1']
  include_ranges [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }]
  exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }]
  include_urls ['file:/opt/opennms/etc/foo']
  store_by_if_alias true
  if_alias_domain 'foo.com'
  remote true
  outage_calendars ['ignore localhost on mondays']
  action :create_if_missing
end

# create_if_missing that doesn't do anything
opennms_collection_package 'create_if_missing' do
  filter "IPADDR != '0.0.0.0'"
  specifics ['10.0.0.1']
  include_ranges [{ 'begin' => '10.0.1.1', 'end' => '10.0.1.254' }]
  exclude_ranges [{ 'begin' => '10.0.2.1', 'end' => '10.0.2.254' }]
  include_urls ['file:/opt/opennms/etc/foo']
  store_by_if_alias true
  if_alias_domain 'foo.com'
  remote true
  outage_calendars ['ignore localhost on mondays']
  action :create_if_missing
end
