# frozen_string_literal: true

control 'event_edit_tticket' do
  title 'OpenNMS Event Trouble Ticket Configuration'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(%w(tticket content)) { should eq 'tticketInfo' }
    its(%w(tticket state)) { should eq 'on' }
  end
end
