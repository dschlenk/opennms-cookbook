# frozen_string_literal: true
control 'snmp_config_definition' do
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

  v1v2c_typical = {
    'read_community' => 'public',
    'version' => 'v2c',
  }
  describe snmp_config_definition(v1v2c_typical) do
    it { should exist }
    its('ranges') { should eq '10.1.0.1' => '10.1.0.254', '172.17.27.1' => '172.17.27.254' }
    its('specifics') { should eq ['192.168.4.1', '192.168.5.2', '192.168.6.3'] }
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

  v3sl1typical = {
    'version' => 'v3',
    'security_name' => 'superSecure',
    'security_level' => 1,
  }
  describe snmp_config_definition(v3sl1typical) do
    it { should exist }
    its('ranges') { should eq '10.1.1.1' => '10.1.1.254', '172.17.37.1' => '172.17.37.254' }
    its('specifics') { should eq ['192.168.11.1', '192.168.12.2', '192.168.13.3'] }
  end

  v3sl2typical = {
    'version' => 'v3',
    'security_name' => 'superSecure',
    'security_level' => 2,
    'auth_passphrase' => '0p3nNMSv3',
    'auth_protocol' => 'SHA',
  }
  describe snmp_config_definition(v3sl2typical) do
    it { should exist }
    its('ranges') { should eq '10.2.1.1' => '10.2.1.254', '172.17.47.1' => '172.17.47.254' }
    its('specifics') { should eq ['192.168.50.1', '192.168.51.2', '192.168.52.3'] }
  end
end
