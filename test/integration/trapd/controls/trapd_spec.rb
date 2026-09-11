require 'json'

opennms_user = input(
  'opennms_username',
  value: 'admin'
)

opennms_password = input(
  'opennms_password',
  value: 'admin'
)

response = http(
  'http://localhost:8980/opennms/api/v2/trapd/config',
  method: 'GET',
  auth: {
    user: opennms_user,
    pass: opennms_password,
  },
  headers: {
    'Accept' => 'application/json',
  }
)

describe response do
  its('status') { should cmp 200 }
end

cfg = JSON.parse(response.body)

control 'trapd-config' do
  impact 1.0
  title 'Trapd configuration is configured'

  describe cfg['batchInterval'] do
    it { should eq 200 }
  end

  describe cfg['batchSize'] do
    it { should eq 500 }
  end

  describe cfg['includeRawMessage'] do
    it { should eq true }
  end

  describe cfg['newSuspectOnTrap'] do
    it { should eq false }
  end

  describe cfg['queueSize'] do
    it { should eq 5000 }
  end

  describe cfg['snmpTrapAddress'] do
    it { should eq '0.0.0.0' }
  end

  describe cfg['snmpTrapPort'] do
    it { should eq 1162 }
  end

  describe cfg['threads'] do
    it { should eq 8 }
  end

  describe cfg['useAddressFromVarbind'] do
    it { should eq true }
  end
end
