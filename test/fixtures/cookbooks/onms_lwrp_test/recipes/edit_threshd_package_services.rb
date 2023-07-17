# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshd_package'
opennms_threshd_package 'change cheftest2 package services' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  services [{ 'name' => 'SNMP', 'interval' => 300_000, 'status' => 'off', 'params' => { 'thresholding-group' => 'cheftest2' } },
            { 'name' => 'ICMP', 'interval' => 300_000, 'status' => 'on', 'params' => { 'thresholding-group' => 'cheftest3' } }]
end
