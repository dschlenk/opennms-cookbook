# frozen_string_literal: true
control 'snmp_config_definition_update' do
  v1v2c_all = {
    'port' => 161,
    'retry_count' => 3,
    'timeout' => 5000,
    'read_community' => 'public',
    'write_community' => 'private',
    'proxy_host' => '192.168.1.1',
    'version' => 'v2c',
    'max_vars_per_pdu' => 20,
    'max_repetitions' => 3,
    'max_request_size' => 65535,
  }
  describe snmp_config_definition(v1v2c_all) do
    it { should exist }
    its('ranges') { should eq '10.0.0.1' => '10.0.0.254', '172.17.16.1' => '172.17.16.254' }
    its('specifics') { should eq ['192.168.0.1', '192.168.1.2', '192.168.2.3'] }
    its('ip_matches') { should eq ['172.17.21.*', '172.17.20.*'] }
  end

  v3all = {
    'port' => 161,
    'retry_count' => 3,
    'timeout' => 5000,
    'proxy_host' => '192.168.1.1',
    'version' => 'v3',
    'max_vars_per_pdu' => 20,
    'max_repetitions' => 3,
    'max_request_size' => 65535,
    'security_name' => 'superSecure',
    'security_level' => 3,
    'auth_passphrase' => '0p3nNMSv3',
    'auth_protocol' => 'SHA',
    'engine_id' => '3ng*n3',
    'context_engine_id' => 'c0nt3xt',
    'context_name' => 'cn@m3',
    'privacy_passphrase' => '0p3nNMSv3',
    'privacy_protocol' => 'AES256',
    'enterprise_id' => '8072',
  }
  describe snmp_config_definition(v3all) do
    it { should exist }
    its('ranges') { should eq '10.0.1.1' => '10.0.1.254', '172.17.17.1' => '172.17.17.254' }
    its('specifics') { should eq ['192.168.10.1', '192.168.11.2', '192.168.12.3'] }
    its('ip_matches') { should eq ['172.17.22.*', '172.17.20.*'] }
  end
end
