# all options
opennms_wmi_config_definition "create_all" do
  retry_count 3
  timeout 5000
  username 'billy'
  domain 'mydomain'
  password 'lolnope'
  ranges '10.0.0.1' => '10.0.0.254', '172.17.16.1' => '172.17.16.254'
  specifics ['192.168.0.1', '192.168.1.2', '192.168.2.3']
  ip_matches ['172.17.21.*','172.17.20.*']
  position 'top'
  notifies :restart, 'service[opennms]'
end

# more typical options
opennms_wmi_config_definition "wmi_typical" do
  username 'bobby'
  domain 'mydomain'
  ranges '10.1.0.1' => '10.1.0.254', '172.17.27.1' => '172.17.27.254'
  specifics ['192.168.4.1', '192.168.5.2', '192.168.6.3']
  notifies :restart, 'service[opennms]'
end

