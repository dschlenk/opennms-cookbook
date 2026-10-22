# frozen_string_literal: true

control 'event_descr' do
  title 'OpenNMS Event Description Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data.dig('events') || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(['descr']) { should eq '<p>A thresholds defined by a chef recipe has been exceeded.</p>' }
  end
end
