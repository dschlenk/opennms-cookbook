# frozen_string_literal: true

control 'event_remove_autoaction' do
  title 'OpenNMS Event Remove Autoaction Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_autoaction', 'events/chef.events.xml') do
    it { should exist }
    its('autoaction') { should be_nil }
  end
end
