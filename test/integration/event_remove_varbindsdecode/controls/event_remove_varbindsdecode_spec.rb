# frozen_string_literal: true

control 'event_remove_varbindsdecode' do
  title 'OpenNMS Event Remove Varbindsdecode Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_varbindsdecode', 'events/chef.events.xml') do
    it { should exist }
    its('varbindsdecode') { should be_nil }
  end
end
