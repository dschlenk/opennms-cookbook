# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshd_package'
opennms_threshd_package 'change cheftest2 package filter and specifics' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.17.1', '172.17.17.2']
end
