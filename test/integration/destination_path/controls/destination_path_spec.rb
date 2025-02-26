control 'destination_path' do
  describe destination_path('foo') do
    it { should exist }
    its('initial_delay') { should eq '5s' }
  end

  describe destination_path('bar') do
    it { should exist }
    its('initial_delay') { should eq '0s' }
  end

  describe destination_path('baz') do
    it { should exist }
    its('initial_delay') { should eq '15s' }
  end

  describe destination_path('delete') do
    it { should_not exist }
  end

  describe destination_path('nope') do
    it { should_not exist }
  end

  describe destination_path('404') do
    it { should_not exist }
  end

  describe target('foo', 'Admin') do
    it { should exist }
    its('commands') { should eq ['javaEmail'] }
    its('auto_notify') { should eq nil }
    its('interval') { should eq nil }
  end

  describe target('bar', 'Admin') do
    it { should exist }
    its('commands') { should eq ['javaPagerEmail'] }
  end

  describe target('baz', 'Admin') do
    it { should exist }
    its('commands') { should eq ['javaPagerEmail'] }
  end

  describe target('baz', 'admin') do
    it { should exist }
    its('commands') { should eq %w(javaEmail javaPagerEmail) }
    its('auto_notify') { should eq 'off' }
    its('interval') { should eq '7s' }
  end

  describe target('baz', 'rtc') do
    it { should exist }
    its('commands') { should eq %w(javaPagerEmail javaEmail) }
    its('auto_notify') { should eq 'auto' }
    its('interval') { should eq '9s' }
  end

  describe target('bar', 'admin') do
    it { should_not exist }
  end

  describe target('foo', 'admin') do
    it { should_not exist }
  end

  describe target('foo', 'Admin', 'escalate') do
    it { should exist }
    its('commands') { should eq ['javaEmail'] }
    its('auto_notify') { should eq nil }
    its('interval') { should eq nil }
    its('delay') { should eq nil }
  end

  describe target('baz', 'admin', 'escalate') do
    it { should exist }
    its('commands') { should eq %w(javaEmail javaPagerEmail) }
    its('auto_notify') { should eq 'off' }
    its('interval') { should eq '7s' }
  end

  describe target('baz', 'rtc', 'escalate') do
    it { should exist }
    its('commands') { should eq %w(javaPagerEmail javaEmail) }
    its('auto_notify') { should eq 'auto' }
    its('interval') { should eq '9s' }
  end

  describe target('bar', 'admin') do
    it { should_not exist }
  end

  describe target('foo', 'admin') do
    it { should_not exist }
  end
end
