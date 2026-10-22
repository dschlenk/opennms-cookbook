# frozen_string_literal: true

control 'event_change_parameters' do
  title 'OpenNMS Event Parameters Modification Fallback Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []
  matched_event = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' }

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { matched_event }

    it { should_not be_nil }

    if matched_event && matched_event['parameter'].nil?
      its(['parameter']) { should be_nil }
    elsif matched_event && matched_event['parameter']&.any? { |p| p.key?('expand') }
      its(['parameter']) { should eq([{ 'name' => 'param1', 'value' => 'value1' }, { 'name' => 'param2', 'value' => 'value2', 'expand' => false }]) }
    else
      its(['parameter']) { should eq([{ 'name' => 'param1', 'value' => 'value1' }, { 'name' => 'param2', 'value' => 'value2' }]) }
    end
  end
end
