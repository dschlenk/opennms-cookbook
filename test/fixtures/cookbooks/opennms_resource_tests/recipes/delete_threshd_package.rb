include_recipe 'opennms_resource_tests::threshd_package'
opennms_threshd_package 'delete cheftest2 threshd package' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  action :delete
end
