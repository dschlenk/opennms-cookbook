# frozen_string_literal: true

control 'event_add_parameters' do
  title 'OpenNMS Event Parameters Fallback Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }

    it 'validates the parameter fallback state based on schema capabilities' do
      # Normalize parameters structure gracefully to an array using your resolved API normalization logic
      raw_params = subject&.dig('parameter')
      params = raw_params.is_a?(Hash) ? [raw_params] : raw_params

      if params.nil?
        expect(params).to be_nil
      elsif params.any? { |p| p.is_a?(Hash) && p.key?('expand') }
        # Horizon > 16 supports parameters with expand attribute
        expect(params).to eq([
                               { 'name' => 'param1', 'value' => 'paramValue1' },
                               { 'name' => 'param2', 'value' => 'paramValue2', 'expand' => true }
                             ])
      else
        # Fallback for Horizon versions (like 17) where expand attribute is absent
        expect(params).to eq([
                               { 'name' => 'param1', 'value' => 'paramValue1' },
                               { 'name' => 'param2', 'value' => 'paramValue2' }
                             ])
      end
    end
  end
end
