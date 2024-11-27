control 'user' do
  describe opennms_user('jimmy', 1234, 'jimmy:abc123') do
    it { should exist }
    its('full_name') { should eq 'Jimmy John' }
    its('user_comments') { should eq 'Sandwiches' }
    its('password_salt') { should eq true }
    its('duty_schedules') { should eq %w(Mo1-300 TuWe301-2359) }
    its('roles') { should eq %w(ROLE_ADMIN ROLE_ASSET_EDITOR ROLE_FILESYSTEM_EDITOR ROLE_DELEGATE ROLE_DEVICE_CONFIG_BACKUP ROLE_JMX ROLE_MINION ROLE_READONLY ROLE_USER ROLE_DASHBOARD ROLE_REST ROLE_RTC ROLE_MOBILE ROLE_FLOW_MANAGER ROLE_REPORT_DESIGNER ROLE_PROVISION) }
  end

  # retrieve data using account created
  describe http('http://127.0.0.1:8980/opennms/rest/users/jimmy', auth: { user: 'jimmy', pass: 'abc123' }, headers: { 'Accept' => 'application/json' }) do
    its('status') { should cmp 200 }
  end

  # minimal
  describe opennms_user('johnny', 1234, 'jimmy:abc123') do
    it { should exist }
  end
end
