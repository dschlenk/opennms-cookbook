# frozen_string_literal: true

control 'event_edit_forward' do
  title 'OpenNMS Event Forward Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(forward)) { should eq([{ 'content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmpudp' }]) }
  end
end
