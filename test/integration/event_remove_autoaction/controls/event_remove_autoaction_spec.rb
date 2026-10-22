# frozen_string_literal: true

control 'event_remove_autoaction' do
  title 'OpenNMS Event Remove Autoaction Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(autoaction)) { should be_nil }
  end
end
