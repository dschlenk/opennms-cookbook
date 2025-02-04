include_recipe 'opennms_resource_tests::threshd_package'
opennms_threshd_service 'WS-Man' do
  package_name 'cheftest2'
  interval 300000
  status 'on'
  user_defined true
  parameters('thresholding-group' => 'cheftest2')
end

opennms_threshd_service 'SNMP' do
  package_name 'mib2'
  interval 300000
  action :update
end

opennms_threshd_service 'SNMP' do
  package_name 'hrstorage'
  action :delete
end

opennms_threshd_service 'SNMP' do
  package_name 'createifmissing'
  action :create_if_missing
end
