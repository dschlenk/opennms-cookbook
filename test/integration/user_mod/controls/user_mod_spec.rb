control 'user_mod' do
  describe opennms_user('jimmy', 1235) do
    it { should exist }
    its('full_name') { should eq 'Jimmy Jam' }
    its('user_comments') { should eq 'The Time' }
    its('roles') { should eq ['ROLE_ADMIN'] }
    its('email') { should eq 'person@example.com' }
    its('duty_schedules') { should eq [] }
  end

  # retrieve data using changed password
  describe http('http://127.0.0.1:8980/opennms/rest/users/jimmy', auth: { user: 'jimmy', pass: 'one2three4' }, headers: { 'Accept' => 'application/json' }) do
    its('status') { should cmp 200 }
  end

  describe opennms_user('johnny', 1235) do
    it { should_not exist }
  end
end
