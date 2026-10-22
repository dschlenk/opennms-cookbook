# frozen_string_literal: true

control 'event_add_parameters' do
  title 'OpenNMS Event Parameters Fallback Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data.dig('events') || []
  matched_event = events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' }

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { matched_event }

    it { should_not be_nil }

    if matched_event && matched_event['parameter'].nil?
      # Handles instances where no parameters are present
      its(['parameter']) { should be_nil }
    elsif matched_event && matched_event['parameter']&.any? { |p| p.key?('expand') }
      # > 16 supports parameters with expand attribute
      its(['parameter']) { should eq([{ 'name' => 'param1', 'value' => 'paramValue1' }, { 'name' => 'param2', 'value' => 'paramValue2', 'expand' => true }]) }
    else
      # except 17 didn't have the expand attribute
      its(['parameter']) { should eq([{ 'name' => 'param1', 'value' => 'paramValue1' }, { 'name' => 'param2', 'value' => 'paramValue2' }]) }
    end
  end
end
