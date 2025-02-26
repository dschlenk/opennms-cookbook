# noop because ip_matches merge not replace
include_recipe 'opennms_resource_tests::wmi_config_definition'
opennms_wmi_config_definition 'update_all' do
  retry_count 3
  timeout 5000
  username 'billy'
  domain 'mydomain'
  password 'lolnope'
  ranges '10.0.0.1' => '10.0.0.254', '172.17.16.1' => '172.17.16.254', '172.17.17.1' => '172.17.17.254'
  specifics ['192.168.0.1', '192.168.1.2', '192.168.2.3', '192.168.3.4']
  ip_matches ['172.17.21.*', '172.17.20.*', '172.17.22.*']
  position 'top'
  notifies :restart, 'service[opennms]'
end

# does nothing if test_wmi_config_definition is earlier in the run_list
opennms_wmi_config_definition 'do_nothing' do
  username 'bobby'
  domain 'mydomain'
  action :create_if_missing
  notifies :restart, 'service[opennms]'
end

# delete
opennms_wmi_config_definition 'delete_typical' do
  username 'bobby'
  domain 'mydomain'
  action :delete
  notifies :restart, 'service[opennms]'
end
