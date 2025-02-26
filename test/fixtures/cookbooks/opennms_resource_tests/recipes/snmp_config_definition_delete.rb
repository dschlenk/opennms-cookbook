include_recipe 'opennms_resource_tests::snmp_config_definition'
# this will delete the existing definition from the standard test
opennms_snmp_config_definition 'update_v1v2c_typical' do
  read_community 'public'
  version 'v2c'
  action :delete
end
