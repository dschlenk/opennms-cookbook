control 'notification_command' do
  describe notification_command('wallHost') do
    it { should exist }
    its('execute') { should eq '/usr/bin/wall' }
    its('contact_type') { should eq 'wall' }
    its('comment') { should eq 'wall the hostname' }
    its('binary') { should eq true }
    its('arguments') { should eq [{ 'streamed' => 'false', 'switch' => '-tm' }] }
    its('service_registry') { should eq false }
  end

  describe notification_command('minimal') do
    it { should exist }
    its('execute') { should eq '/bin/true' }
    its('binary') { should eq true }
    its('contact_type') { should eq nil }
    its('comment') { should eq nil }
    its('arguments') { should eq nil }
    its('service_registry') { should eq nil }
  end

  describe notification_command('to update') do
    it { should exist }
    its('execute') { should eq '/bin/sh' }
    its('binary') { should eq false }
    its('contact_type') { should eq 'fax' }
    its('comment') { should eq 'testing update' }
    its('arguments') { should eq [{ 'streamed' => 'false', 'switch' => '-tm' }] }
    its('service_registry') { should eq false }
  end

  describe notification_command('create_if_missing') do
    it { should exist }
    its('execute') { should eq '/bin/false' }
    its('binary') { should eq true }
    its('contact_type') { should eq nil }
    its('comment') { should eq nil }
    its('arguments') { should eq nil }
    its('service_registry') { should eq nil }
  end

  describe notification_command('delete') do
    it { should_not exist }
  end

  describe notification_command('foo') do
    it { should_not exist }
  end

  describe destination_path('wibble') do
    it { should exist }
  end

  describe target('wibble', 'Admin') do
    it { should exist }
    its('commands') { should eq ['wallHost'] }
  end

  describe target('Email-Admin', 'Admin', true) do
    it { should exist }
    its('commands') { should eq ['wallHost'] }
    its('auto_notify') { should eq 'on' }
    its('interval') { should eq '1s' }
    its('escalate_delay') { should eq '30s' }
  end
end
