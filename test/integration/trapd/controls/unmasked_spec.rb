control 'trapd-download-unmasked' do
  describe snmpv3user('trapuser', 3, 'SHA', 'AES') do
    it { should exist }
    its('auth_passphrase') { should_not match(/^\*+$/) }
    its('auth_passphrase') { should eq 'authsecret' }
    its('privacy_passphrase') { should_not match(/^\*+$/) }
    its('privacy_passphrase') { should eq 'privsecret' }
  end
end
