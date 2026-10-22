# frozen_string_literal: true

control 'event_logmsg_dest' do
  title 'OpenNMS Event Logmsg Destination Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(logmsg dest)) { should eq 'discardtraps' }
  end
end
