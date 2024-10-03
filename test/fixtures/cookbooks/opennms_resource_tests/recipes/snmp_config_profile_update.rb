include_recipe 'opennms_resource_tests::snmp_config_profile'

opennms_snmp_config_profile 'foo' do
  port 161
  retry_count 2
  timeout 7000
  read_community 'bear'
  write_community'quux'
  proxy_host '127.0.0.2'
  version 'v1'
end
