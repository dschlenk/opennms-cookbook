include_recipe 'opennms_resource_tests::snmp_config_definition'
opennms_snmp_config_profile 'foo' do
  port 171
  retry_count 2
  timeout 6000
  read_community 'bar'
  write_community 'qux'
  proxy_host '127.0.0.1'
  version 'v2c'
  max_vars_per_pdu 30
  max_repetitions 4
  max_request_size 33001
  filter "iphostname LIKE '%opennms%'"
end

opennms_snmp_config_definition 'uses profile foo' do
  profile_label 'foo'
  ranges [{ '10.1.1.2' => '10.1.1.3' }]
  specifics ['10.1.1.4']
end

opennms_snmp_config_definition 'uses profile foo at location bar' do
  profile_label 'foo'
  location 'bar'
  ranges [{ '10.3.1.2' => '10.3.1.3' }]
  specifics ['10.3.1.4']
end
