# this will modify the existing definition from the standard test
opennms_snmp_config_definition "update_v1v2c_all" do
  port 161
  retry_count 3
  timeout 5000
  read_community 'public'
  write_community 'private'
  proxy_host '192.168.1.1'
  version 'v2c'
  max_vars_per_pdu 20
  max_repetitions 3
  max_request_size 65535
  specifics ['192.168.0.1', '192.168.2.3']
  position 'top'
  action :create
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end

# this will delete the existing definition from the standard test
opennms_snmp_config_definition "update_v1v2c_typical" do
  read_community 'public'
  version 'v2c'
  action :delete
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end



# this will do nothing even though the ranges, specifics and ip_matches are different since action :create_if_missing is chosen.
opennms_snmp_config_definition "update_v3all" do
  port 161
  retry_count 3
  timeout 5000
  proxy_host '192.168.1.1'
  version 'v3'
  max_vars_per_pdu 20
  max_repetitions 3
  max_request_size 65535
  security_name "superSecure"
  security_level 3
  auth_passphrase "0p3nNMSv3"
  auth_protocol "SHA"
  engine_id "3ng*n3"
  context_engine_id "c0nt3xt"
  context_name "cn@m3"
  privacy_passphrase "0p3nNMSv3"
  privacy_protocol "AES256"
  enterprise_id "8072" # maybe set this to your org's private enterprise number? who knows!
  position 'bottom'
  action :create_if_missing
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end
