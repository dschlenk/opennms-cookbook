# frozen_string_literal: true

control 'event_edit_autoaction' do
  title 'OpenNMS Event Autoaction Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('autoaction') { should eq([{ 'content' => 'someaction2', 'state' => 'on' }]) }
  end
end
