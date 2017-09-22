# frozen_string_literal: true
control 'group' do
  describe group('nerds') do
    it { should exist }
    its('users') { should eq ['admin'] }
    its('duty_schedules') { should eq ['MoTuWeThFrSaSu800-1700'] }
    its('comments') { should eq 'pocket protectors and such' }
  end
end
