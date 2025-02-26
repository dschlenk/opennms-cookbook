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
    its('parameters') { should eq '-subject' => 'EMERGENCY' }
  end

  describe notification('example2Broken') do
    it { should exist }
    its('status') { should eq 'on' }
    its('uei') { should eq 'example2/exampleBroken' }
    its('destination_path') { should eq 'Email-Admin' }
    its('text_message') { should eq 'broken' }
    its('writeable') { should eq nil }
    its('rule') { should eq "IPADDR != '0.0.0.0'" }
    its('strict_rule') { should eq nil }
    its('description') { should eq nil }
    its('subject') { should eq nil }
    its('numeric_message') { should eq nil }
    its('event_severity') { should eq nil }
    its('vbname') { should eq nil }
    its('vbvalue') { should eq nil }
    its('parameters') { should eq nil }
  end

  describe notification('something2Update') do
    it { should exist }
    its('status') { should eq 'off' }
    its('uei') { should eq 'notifUpdated' }
    its('destination_path') { should eq 'Email-Admin' }
    its('text_message') { should eq 'updated notification' }
    its('writeable') { should eq nil }
    its('rule') { should eq "IPADDR != '0.0.0.1'" }
    its('strict_rule') { should eq true }
    its('description') { should eq 'boop' }
    its('subject') { should eq nil }
    its('numeric_message') { should eq nil }
    its('event_severity') { should eq nil }
    its('vbname') { should eq 'snmpifdescr' }
    its('vbvalue') { should eq '3Com 905B Fast Ethernet' }
    its('parameters') { should eq nil }
  end

  describe notification('delete') do
    it { should_not exist }
  end

  describe notification('delete nothing') do
    it { should_not exist }
  end

  describe notification('actionable create_if_missing') do
    it { should exist }
    its('status') { should eq 'on' }
    its('uei') { should eq 'createIfMissing' }
    its('destination_path') { should eq 'Email-Admin' }
    its('text_message') { should eq 'create_if_missing' }
    its('writeable') { should eq nil }
    its('rule') { should eq "IPADDR != '0.0.0.0'" }
    its('strict_rule') { should eq nil }
    its('description') { should eq nil }
    its('subject') { should eq nil }
    its('numeric_message') { should eq nil }
    its('event_severity') { should eq nil }
    its('vbname') { should eq nil }
    its('vbvalue') { should eq nil }
    its('parameters') { should eq nil }
  end
end
