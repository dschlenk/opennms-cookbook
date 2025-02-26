include_recipe 'opennms_resource_tests::threshd_package'
opennms_threshd_package 'change cheftest2 package filter' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0' & IPADDR != '1.1.1.1'"
end
