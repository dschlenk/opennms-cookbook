# frozen_string_literal: true
opennms_threshd_package 'create cheftest2 with package_name' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.17.1']
  include_ranges [{ 'begin' => '172.17.14.1', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }]
  exclude_ranges [{ 'begin' => '10.1.0.1', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include2']
  services [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }]
  notifies :run, 'opennms_send_event[restart_Threshd]'
end
