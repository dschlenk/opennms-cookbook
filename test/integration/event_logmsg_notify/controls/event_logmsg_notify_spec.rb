# frozen_string_literal: true

control 'event_logmsg_notify' do
  title 'OpenNMS Event Logmsg Notify Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg_notify', 'events/chef.events.xml') do
    it { should exist }

    it 'validates the logmsg notify configuration' do
      logmsg = subject['logmsg']
      expect(logmsg).not_to be_nil
      expect(['false', '']).to include(logmsg['notify'].to_s)
    end
  end
end
