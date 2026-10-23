# frozen_string_literal: true

control 'event_remove_forward' do
  title 'OpenNMS Event Remove Forward Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_forward', 'events/chef.events.xml') do
    it { should exist }
    # Handles both an empty collection or a completely dropped nil attribute safely
    its('forward') { should be_nil.or be_empty }
  end
end
