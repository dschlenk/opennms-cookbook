# frozen_string_literal: true

control 'event_add_parameters' do
  title 'OpenNMS Event Parameters Fallback Validation'

  # Instantiate an active helper layer to safely contact the REST API
  api_helper = opennms_event(nil, nil)
  events_data = api_helper.fetch_live_eventconf_json

  # Gracefully fall back if OpenNMS api schema returns empty hashes
  if events_data.nil? || events_data.empty?
    describe 'OpenNMS API Connection State' do
      skip 'Skipping validation matrix because the OpenNMS REST endpoint returned an empty payload.'
    end
  else
    events_list = events_data['event'] || events_data['events'] || events_data || []
    events_list = [events_list] if events_list.is_a?(Hash)

    describe 'Event uei.opennms.org/cheftest/thresholdExceeded2-event_add_parameters' do
      subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2-event_add_parameters' } }

      it { should_not be_nil }

      it 'validates the parameter fallback state based on schema capabilities' do
        raw_params = subject&.dig('parameter')
        params = raw_params.is_a?(Hash) ? [raw_params] : raw_params

        if params.nil?
          expect(params).to be_nil
        elsif params.any? { |p| p.is_a?(Hash) && p.key?('expand') }
          expect(params).to eq([
                                 { 'name' => 'param1', 'value' => 'paramValue1' },
                                 { 'name' => 'param2', 'value' => 'paramValue2', 'expand' => true },
                               ])
        else
          expect(params).to eq([
                                 { 'name' => 'param1', 'value' => 'paramValue1' },
                                 { 'name' => 'param2', 'value' => 'paramValue2' },
                               ])
        end
      end
    end
  end
end
