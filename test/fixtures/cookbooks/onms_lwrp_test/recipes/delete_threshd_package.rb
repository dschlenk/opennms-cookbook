# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshd_package'
opennms_threshd_package 'delete cheftest2 threshd package' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  action :delete
end
