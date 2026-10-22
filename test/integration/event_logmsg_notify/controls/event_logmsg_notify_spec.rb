# frozen_string_literal: true

control 'event_logmsg_notify' do
  title 'OpenNMS Event Logmsg Notify Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('logmsg.notify') { should be false }
  end
end
