# frozen_string_literal: true
control 'user' do
  describe opennms_user('jimmy') do
    it { should exist }
    its('full_name') { should eq 'Jimmy John' }
    its('user_comments') { should eq 'Sandwiches' }
    its('password') { should eq '6D639656F5EAC2E799D32870DD86046D' }
    its('password_salt') { should eq false }
  end

  # minimal
  describe opennms_user('johnny') do
    it { should exist }
  end
end
