# frozen_string_literal: true

control 'event_remove_add_forward' do
  title 'OpenNMS Event Remove and Add Forward Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_forward', 'events/chef.events.xml') do
    it { should exist }
    its('forward') { should eq([{ 'content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
  end
end
