# frozen_string_literal: true

control 'event_logmsg_dest' do
  title 'OpenNMS Event Logmsg Destination Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg_dest', 'events/chef.events.xml') do
    it { should exist }

    it 'validates the logmsg destination property' do
      logmsg = subject['logmsg']
      expect(logmsg).not_to be_nil
      expect(logmsg['dest']).to eq 'discardtraps'
    end
  end
end
