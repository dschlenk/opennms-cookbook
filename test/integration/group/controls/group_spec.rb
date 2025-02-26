control 'group' do
  describe opennms_group('nerds') do
    it { should exist }
    its('users') { should eq ['admin'] }
    its('duty_schedules') { should eq ['MoTuWeThFrSaSu800-1700'] }
    its('comments') { should eq 'pocket protectors and such' }
  end

  describe opennms_group('minimal') do
    it { should exist }
    its('users') { should eq ['admin'] }
    its('duty_schedules') { should eq nil }
    its('comments') { should eq nil }
  end

  describe opennms_group('update') do
    it { should exist }
    its('users') { should eq %w(admin rtc) }
    its('duty_schedules') { should eq ['MoTuWeThFrSaSu800-1700'] }
    its('comments') { should eq 'barf' }
  end

  describe opennms_group('create_delete') do
    it { should_not exist }
  end

  describe opennms_group('foo') do
    it { should_not exist }
  end
end
