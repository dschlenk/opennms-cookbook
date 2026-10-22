# frozen_string_literal: true

control 'event_remove_varbindsdecode' do
  title 'OpenNMS Event Remove Varbindsdecode Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(varbindsdecode)) { should be_nil }
  end
end
