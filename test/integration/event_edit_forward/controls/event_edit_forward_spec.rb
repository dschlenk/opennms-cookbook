# frozen_string_literal: true

control 'event_edit_forward' do
  title 'OpenNMS Event Forward Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_forward', 'events/chef.events.xml') do
    it { should exist }
    its('forward') { should eq([{ 'content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmpudp' }]) }
  end
end
