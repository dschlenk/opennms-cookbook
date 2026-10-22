# frozen_string_literal: true

control 'event_edit_mouseovertext' do
  title 'OpenNMS Event Mouseovertext Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('mouseovertext') { should eq 'mouseOverTexted' }
  end
end
