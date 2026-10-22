# frozen_string_literal: true

control 'event_severity' do
  title 'OpenNMS Event Severity Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(severity)) { should eq 'Warning' }
  end
end
