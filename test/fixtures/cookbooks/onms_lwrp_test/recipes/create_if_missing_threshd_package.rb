# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshd_package'
# this should do nothing
opennms_threshd_package 'create_if_missing cheftest2 with package_name' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.1'"
  specifics ['172.17.17.2']
  include_ranges [{ 'begin' => '172.17.14.2', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }]
  exclude_ranges [{ 'begin' => '10.1.0.3', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include3']
  services [{ 'name' => 'SNMP', 'interval' => 300_001, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }]
  notifies :run, 'opennms_send_event[restart_Threshd]'
  action :create_if_missing
end

# this should do something
opennms_threshd_package 'create_if_missing cheftest3 with package_name' do
  package_name 'cheftest3'
  filter "IPADDR != '0.0.0.1'"
  specifics ['172.17.17.2']
  include_ranges [{ 'begin' => '172.17.14.2', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }]
  exclude_ranges [{ 'begin' => '10.1.0.3', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include3']
  services [{ 'name' => 'SNMP', 'interval' => 300_001, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }]
  notifies :run, 'opennms_send_event[restart_Threshd]'
  action :create_if_missing
end

# this should do nothing
opennms_threshd_package 'create_if_missing cheftest3 with package_name change' do
  package_name 'cheftest3'
  filter "IPADDR != '0.0.0.2'"
  specifics ['172.17.17.1']
  include_ranges [{ 'begin' => '172.17.14.2', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }]
  exclude_ranges [{ 'begin' => '10.1.0.4', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include3']
  services [{ 'name' => 'SNMP', 'interval' => 300_001, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }]
  notifies :run, 'opennms_send_event[restart_Threshd]'
  action :create_if_missing
end
