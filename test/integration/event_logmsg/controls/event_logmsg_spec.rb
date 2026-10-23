# frozen_string_literal: true

control 'event_logmsg' do
  title 'OpenNMS Event Logmsg Destination Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg', 'events/chef.events.xml') do
    it { should exist }
    its('logmsg.dest') { should eq 'discardtraps' }
  end
end
