# frozen_string_literal: true

control 'event_edit_autoaction' do
  title 'OpenNMS Event Autoaction Configuration'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data.dig('events') || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(['autoaction']) { should eq([{ 'content' => 'someaction2', 'state' => 'on' }]) }
  end
end
