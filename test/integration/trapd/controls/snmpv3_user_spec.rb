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
  'http://localhost:8980/opennms/api/v2/trapd/download',
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

users = cfg.fetch('snmpv3User', [])

control 'trapd-noauth-user' do
  impact 1.0

  user =
    users.find do |u|
      u['securityName'] == 'readonly' &&
        u['securityLevel'] == 1
    end

  describe user do
    it { should_not be_nil }
  end

  describe user['authProtocol'] do
    it { should be_nil }
  end

  describe user['privacyProtocol'] do
    it { should be_nil }
  end
end

control 'trapd-auth-user' do
  impact 1.0

  user =
    users.find do |u|
      u['securityName'] == 'monitor' &&
        u['securityLevel'] == 2 &&
        u['authProtocol'] == 'SHA'
    end

  describe user do
    it { should_not be_nil }
  end

  describe user['authPassphrase'] do
    it { should eq 'authsecret' }
  end

  describe user['privacyProtocol'] do
    it { should be_nil }
  end
end

control 'trapd-authpriv-user-no-engine' do
  impact 1.0

  user =
    users.find do |u|
      u['securityName'] == 'trapuser' &&
        u['securityLevel'] == 3 &&
        u['authProtocol'] == 'SHA' &&
        u['privacyProtocol'] == 'AES' &&
        u['engineId'].nil?
    end

  describe user do
    it { should_not be_nil }
  end

  describe user['authPassphrase'] do
    it { should eq 'authsecret' }
  end

  describe user['privacyPassphrase'] do
    it { should eq 'privsecret' }
  end
end

control 'trapd-authpriv-user-with-engine' do
  impact 1.0

  user =
    users.find do |u|
      u['securityName'] == 'trapuser' &&
        u['engineId'] == '8000000001020304' &&
        u['securityLevel'] == 3 &&
        u['authProtocol'] == 'SHA' &&
        u['privacyProtocol'] == 'AES'
    end

  describe user do
    it { should_not be_nil }
  end

  describe user['authPassphrase'] do
    it { should eq 'engineauthsecret' }
  end

  describe user['privacyPassphrase'] do
    it { should eq 'engineprivsecret' }
  end
end
