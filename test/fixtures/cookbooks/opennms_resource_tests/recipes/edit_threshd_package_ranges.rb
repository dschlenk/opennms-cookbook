include_recipe 'opennms_resource_tests::threshd_package'
opennms_threshd_package 'change cheftest2 package filter and ranges' do
  package_name 'cheftest2'
  filter "IPADDR != '0.0.0.0'"
  include_ranges [{ 'begin' => '172.17.14.1', 'end' => '172.17.14.254' }, { 'begin' => '172.17.20.1', 'end' => '172.17.21.254' }]
  exclude_ranges []
end
