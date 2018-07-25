# frozen_string_literal: true
control 'update_wmi_config_definition' do
  all = {
    'username' => 'billy',
    'domain' => 'mydomain',
    'password' => 'lolnope',
    'timeout' => 5000,
    'retry_count' => 3,
  }
  describe wmi_config_definition(all) do
    it { should exist }
    its('ranges') { should eq '10.0.0.1' => '10.0.0.254', '172.17.16.1' => '172.17.16.254', '172.17.17.1' => '172.17.17.254' }
    its('specifics') { should eq ['192.168.0.1', '192.168.1.2', '192.168.2.3', '192.168.3.4'] }
    its('ip_matches') { should eq ['172.17.21.*', '172.17.20.*', '172.17.22.*'] }
  end

  typ = {
    'username' => 'bobby',
    'domain' => 'mydomain',
  }
  describe wmi_config_definition(typ) do
    it { should_not exist }
  end
end
