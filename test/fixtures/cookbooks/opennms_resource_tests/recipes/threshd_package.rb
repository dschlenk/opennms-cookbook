opennms_threshd_package 'create cheftest2 with package_name' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.17.1']
  include_ranges [{ 'begin' => '172.17.14.1', 'end' => '172.17.14.254' }, { 'begin' => '172.17.21.1', 'end' => '172.17.21.254' }]
  exclude_ranges [{ 'begin' => '10.1.0.1', 'end' => '10.254.254.254' }]
  include_urls ['file:/opt/opennms/etc/include2']
  services [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest2' } }]
end

opennms_threshd_package 'mib2' do
  filter "IPADDR != '0.0.0.0' & IPADDR != '255.255.255.255'"
  specifics ['1.0.0.1', '1.0.0.2']
  include_ranges [{ 'begin' => '1.0.0.1', 'end' => '223.255.255.254' }]
  exclude_ranges [{ 'begin' => '224.0.0.1', 'end' => '255.255.255.255' }]
  include_urls ['file:/opt/opennms/etc/include']
  services [{ 'name' => 'SNMP', 'interval' => 300_001, 'status' => 'off', 'params' => { 'thresholding-group' => 'mibtoo' } }, { 'name' => 'SNMPv3', 'interval' => 600000, 'status' => 'on' }]
  action :update
end

opennms_threshd_package 'hrstorage' do
  filter "IPADDR != '0.0.0.0' & IPADDR != '255.255.255.255'"
  specifics ['1.0.0.1', '1.0.0.2']
  include_ranges [{ 'begin' => '1.0.0.1', 'end' => '223.255.255.254' }]
  exclude_ranges [{ 'begin' => '224.0.0.1', 'end' => '255.255.255.255' }]
  include_urls ['file:/opt/opennms/etc/include']
  services [{ 'name' => 'SNMP', 'interval' => 300_001, 'status' => 'off' }]
  action :create_if_missing
end

opennms_threshd_package 'juniper-srx' do
  filter 'delete'
  action :delete
end
