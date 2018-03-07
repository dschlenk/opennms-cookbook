# frozen_string_literal: true
control 'notification' do
  describe notification('exampleDown') do
    it { should exist }
    its('status') { should eq 'on' }
    its('writeable') { should eq 'yes' }
    its('uei') { should eq 'uei.opennms.org/example/exampleDown' }
    its('description') { should eq 'An example of a down type event notification.' }
    its('rule') { should eq "IPADDR != '0.0.0.0'" }
    its('destination_path') { should eq 'Email-Admin' }
    its('text_message') { should eq 'Your service is bad and you should feel bad.' }
    its('subject') { should eq 'Bad service.' }
    its('numeric_message') { should eq '31337' }
    its('event_severity') { should eq 'Major' }
    its('vbname') { should eq 'snmpifname' }
    its('vbvalue') { should eq 'eth0' }
  end

  describe notification('example2Broken') do
    it { should exist }
    its('status') { should eq 'on' }
    its('uei') { should eq 'example2/exampleBroken' }
    its('destination_path') { should eq 'Email-Admin' }
    its('text_message') { should eq 'broken' }
    its('writeable') { should eq 'yes' }
    its('rule') { should eq "IPADDR != '0.0.0.0'" }
  end
end
