# frozen_string_literal: true

control 'event_remove_forward' do
  title 'OpenNMS Event Remove Forward Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_forward', 'events/chef.events.xml') do
    it { should exist }
    its('forward') { should be_nil }
  end
end
