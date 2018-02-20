# frozen_string_literal: true
control 'notification_command' do
  describe notification_command('wallHost') do
    it { should exist }
    its('execute') { should eq '/usr/bin/wall' }
    its('contact_type') { should eq 'wall' }
    its('comment') { should eq 'wall the hostname' }
    its('binary') { should eq true }
    its('arguments') { should eq [{ 'streamed' => 'false', 'switch' => '-tm' }] }
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
