# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshd_package'
opennms_threshd_package 'change cheftest2 package filter and include_urls' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  include_urls ['file:/opt/opennms/etc/include']
end
