control 'dashlet_update' do
  describe wallboard('schlazorboard') do
    it { should exist }
    it { should be_default }
  end

  describe dashlet('summary2', 'schlazorboard') do
    it { should exist }
    its('dashlet_name') { should eq 'RTC' }
    its('boost_duration') { should eq 4 }
    its('boost_priority') { should eq 3 }
    its('duration') { should eq 7 }
    its('priority') { should eq 6 }
    its('parameters') { should eq nil }
  end

  describe dashlet('summary3', 'schlazorboard') do
    it { should_not exist }
  end

  describe dashlet('rtc', 'schlazorboard') do
    it { should exist }
    its('dashlet_name') { should eq 'RTC' }
    its('parameters') { should eq nil }
    its('boost_duration') { should eq 0 }
    its('boost_priority') { should eq 0 }
    its('duration') { should eq 15 }
    its('priority') { should eq 5 }
    its('parameters') { should eq nil }
  end
end
