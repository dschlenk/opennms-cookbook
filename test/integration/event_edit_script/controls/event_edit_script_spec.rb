# frozen_string_literal: true

control 'event_edit_script' do
  title 'OpenNMS Event Script Configuration'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(['script']) { should eq([{ 'content' => 'anScript', 'language' => 'beanshell' }]) }
  end
end
