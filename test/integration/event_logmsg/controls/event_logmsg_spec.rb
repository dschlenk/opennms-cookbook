# frozen_string_literal: true

control 'event_logmsg' do
  title 'OpenNMS Event Logmsg Content Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg', 'events/chef.events.xml') do
    it { should exist }
    its('logmsg.content') { should eq 'A thresholds has been exceeded.' }
  end
end
