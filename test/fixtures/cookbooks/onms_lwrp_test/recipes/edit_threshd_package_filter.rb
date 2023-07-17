# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshd_package'
opennms_threshd_package 'change cheftest2 package filter' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0' & IPADDR != '1.1.1.1'"
end
