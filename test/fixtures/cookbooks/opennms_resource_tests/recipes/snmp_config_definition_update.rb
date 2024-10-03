include_recipe 'opennms_resource_tests::snmp_config_definition'
# doesn't do anything, because those IPs are already present and we merge, not replace specifics, ranges, etc.
opennms_snmp_config_definition 'update_v1v2c_all' do
  port 161
  retry_count 3
  timeout 5000
  read_community 'public'
  write_community 'private'
  proxy_host '192.168.1.1'
  version 'v2c'
  max_vars_per_pdu 20
  max_repetitions 3
  max_request_size 65_535
  specifics ['192.168.0.1', '192.168.2.3']
  action :add
end
