control 'trapd-noauth-user' do
  describe snmpv3user('readonly', 1) do
    it { should exist }
    its('auth_passphrase') { should be_nil }
    its('privacy_passphrase') { should be_nil }
  end
end

control 'trapd-auth-user' do
  describe snmpv3user('monitor', 2, 'SHA') do
    it { should exist }
    its('auth_passphrase') { should eq 'authsecret' }
    its('privacy_passphrase') { should be_nil }
  end
end

control 'trapd-authpriv-user-no-engine' do
  describe snmpv3user('trapuser', 3, 'SHA', 'AES') do
    it { should exist }
    its('auth_passphrase') { should eq 'authsecret' }
    its('privacy_passphrase') { should eq 'privsecret' }
  end
end

control 'trapd-authpriv-user-with-engine' do
  describe snmpv3user('trapuser', 3, 'SHA', 'AES', '8000000001020304') do
    it { should exist }
    its('auth_passphrase') { should eq 'engineauthsecret' }
    its('privacy_passphrase') { should eq 'engineprivsecret' }
  end
end

control 'doomed-user-does-not-exist' do
  describe snmpv3user('doomed', 1) do
    it { should_not exist }
  end
end
