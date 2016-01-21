# all v1 & v2c options
opennms_snmp_config_definition "v1v2c_all" do
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
  ranges '10.0.0.1' => '10.0.0.254', '172.17.16.1' => '172.17.16.254'
  specifics ['192.168.0.1', '192.168.1.2', '192.168.2.3']
  ip_matches ['172.17.21.*','172.17.20.*']
  position 'top'
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end

# more typical v1 and v2c options
opennms_snmp_config_definition "v1v2c_typical" do
  read_community 'public'
  version 'v2c'
  ranges '10.1.0.1' => '10.1.0.254', '172.17.27.1' => '172.17.27.254'
  specifics ['192.168.4.1', '192.168.5.2', '192.168.6.3']
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end

# all v3 options - security level 3 means authPriv
opennms_snmp_config_definition "v3all" do
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
  ranges '10.0.1.1' => '10.0.1.254', '172.17.17.1' => '172.17.17.254'
  specifics ['192.168.10.1', '192.168.11.2', '192.168.12.3']
  ip_matches ['172.17.22.*','172.17.20.*']
  position 'bottom'
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end

# v3 typical options for security-level 1 (noAuthNoPriv)
opennms_snmp_config_definition "v3sl1typical" do
  version 'v3'
  security_name "superSecure"
  security_level 1
  ranges '10.1.1.1' => '10.1.1.254', '172.17.37.1' => '172.17.37.254'
  specifics ['192.168.11.1', '192.168.12.2', '192.168.13.3']
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end

# v3 typical options for security-level 2 (authNoPriv)
opennms_snmp_config_definition "v3sl2typical" do
  version 'v3'
  security_name "superSecure"
  security_level 2
  auth_passphrase "0p3nNMSv3"
  auth_protocol "SHA"
  ranges '10.2.1.1' => '10.2.1.254', '172.17.47.1' => '172.17.47.254'
  specifics ['192.168.50.1', '192.168.51.2', '192.168.52.3']
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end
