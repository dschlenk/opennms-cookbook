# frozen_string_literal: true

control 'event_remove_forward' do
  title 'OpenNMS Event Remove Forward Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(forward)) { should be_nil }
  end
end
