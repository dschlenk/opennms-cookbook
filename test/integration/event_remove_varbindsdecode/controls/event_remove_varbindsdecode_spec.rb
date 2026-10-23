# frozen_string_literal: true

control 'event_remove_varbindsdecode' do
  title 'OpenNMS Event Remove Varbindsdecode Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_varbindsdecode', 'events/chef.events.xml') do
    it { should exist }
    # Handles both an empty collection or a completely dropped nil attribute safely
    its('varbindsdecode') { should be_nil.or be_empty }
  end
end
