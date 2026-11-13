# frozen_string_literal: true

control 'event_severity' do
  title 'OpenNMS Event Severity Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_severity', 'events/chef.events.xml') do
    it { should exist }
    its('severity') { should eq 'Warning' }
  end
end
