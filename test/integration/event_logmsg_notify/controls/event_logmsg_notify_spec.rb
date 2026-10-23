# frozen_string_literal: true

control 'event_logmsg_notify' do
  title 'OpenNMS Event Logmsg Notify Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('events/chef.events.xml')

  raw_events = events_data['event'] || events_data['events'] || []
  events_list = raw_events.is_a?(Hash) ? [raw_events] : raw_events

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg_notify' do
    # Pinpoint the exact event entry from the live payload list
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2-event_logmsg_notify' } }

    it { should_not be_nil }

    it 'validates that logmsg notify attribute is disabled' do
      logmsg = subject&.dig('logmsg')
      notify_val = logmsg.is_a?(Hash) ? logmsg['notify'] : logmsg&.dig(0, 'notify')

      expect(notify_val).to be false
    end
  end
end
