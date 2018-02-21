# frozen_string_literal: true
control 'role' do
  describe onms_group('rolegroup') do
    it { should exist }
    its('comments') { should eq 'pocket protectors and such' }
    its('users') { should eq ['admin'] }
    its('duty_schedules') { should eq ['MoTuWeThFrSaSu800-1700'] }
  end

  describe role('chefrole') do
    it { should exist }
    its('membership_group') { should eq 'rolegroup' }
    its('supervisor') { should eq 'admin' }
    its('description') { should eq 'testing role creation from chef' }
  end

  describe role_schedule('specific', 'chefrole', 'admin') do
    it { should exist }
    its('times') { should eq [{ 'begins' => '20-Mar-2014 00:00:00', 'ends' => '20-Mar-2014 11:00:00' }, { 'begins' => '21-Mar-2014 15:00:00', 'ends' => '21-Mar-2014 23:00:00' }] }
  end

  describe role_schedule('daily', 'chefrole', 'admin') do
    it { should exist }
    its('times') { should eq [{ 'begins' => '08:00:00', 'ends' => '09:00:00' }] }
  end

  describe role_schedule('weekly', 'chefrole', 'admin') do
    it { should exist }
    its('times') { should eq [{ 'begins' => '08:00:00', 'ends' => '17:00:00', 'day' => 'monday' }, { 'begins' => '09:00:00', 'ends' => '18:00:00', 'day' => 'tuesday' }] }
  end

  describe role_schedule('monthly', 'chefrole', 'admin') do
    it { should exist }
    its('times') { should eq [{ 'begins' => '22:00:00', 'ends' => '23:00:00', 'day' => '1' }, { 'begins' => '21:00:00', 'ends' => '23:00:00', 'day' => '15' }] }
  end
end
