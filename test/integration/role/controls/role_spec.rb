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

  describe role('updaterole') do
    it { should exist }
    its('membership_group') { should eq 'updategroup' }
    its('supervisor') { should eq 'rtc' }
    its('description') { should eq 'spoon' }
  end

  describe role('deleterole') do
    it { should_not exist }
  end

  describe role('rule') do
    it { should_not exist }
  end

  describe role_schedule('specific', 'chefrole', 'admin', [{ 'begins' => '20-Mar-2014 00:00:00', 'ends' => '20-Mar-2014 11:00:00' }, { 'begins' => '21-Mar-2014 15:00:00', 'ends' => '21-Mar-2014 23:00:00' }]) do
    it { should exist }
  end

  describe role_schedule('specific', 'chefrole', 'admin', [{ 'begins' => '20-Mar-2014 00:00:00', 'ends' => '20-Mar-2014 11:00:00' }, { 'begins' => '21-Mar-2014 15:00:00', 'ends' => '21-Mar-2014 23:00:00' }, { 'begins' => '21-Mar-2014 23:00:02', 'ends' => '21-Mar-2014 23:01:03' }]) do
    it { should exist }
  end

  describe role_schedule('specific', 'chefrole', 'admin', [{ 'begins' => '20-Mar-2014 00:00:00', 'ends' => '20-Mar-2014 11:00:00' }, { 'begins' => '21-Mar-2014 23:00:02', 'ends' => '21-Mar-2014 23:01:03' }]) do
    it { should_not exist }
  end

  describe role_schedule('daily', 'chefrole', 'admin', [{ 'begins' => '08:00:00', 'ends' => '09:00:00' }]) do
    it { should exist }
  end

  describe role_schedule('weekly', 'chefrole', 'admin', [{ 'begins' => '08:00:00', 'ends' => '17:00:00', 'day' => 'monday' }, { 'begins' => '09:00:00', 'ends' => '18:00:00', 'day' => 'tuesday' }]) do
    it { should exist }
  end

  describe role_schedule('monthly', 'chefrole', 'admin', [{ 'begins' => '22:00:00', 'ends' => '23:00:00', 'day' => '1' }, { 'begins' => '21:00:00', 'ends' => '23:00:00', 'day' => '15' }]) do
    it { should exist }
  end
end
