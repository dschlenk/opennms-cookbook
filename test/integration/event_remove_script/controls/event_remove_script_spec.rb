# frozen_string_literal: true

control 'event_remove_script' do
  title 'OpenNMS Event Remove Script Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(script)) { should be_nil }
  end
end
