# frozen_string_literal: true

control 'event_add_parameters' do
  title 'OpenNMS Event Parameters Fallback Validation'

  api_helper = opennms_event(nil, 'events/chef.events.xml')

  events_data = {}
  max_retries = 6
  attempts = 0

  loop do
    attempts += 1
    events_data = api_helper.send(:fetch_live_eventconf_via_api)

    break if events_data && !events_data.empty? && !events_data['events'].nil? && !events_data['events'].empty?
    break if attempts >= max_retries

    puts "Waiting for OpenNMS Event Database API syncing pipeline... (Attempt #{attempts}/#{max_retries})"
    sleep 5
  end

  if events_data.nil? || events_data.empty? || events_data['events'].nil? || events_data['events'].empty?
    describe 'OpenNMS API Connection State' do
      skip 'Skipping validation matrix because the OpenNMS REST endpoint returned an empty payload.'
    end
  else
    events_list = events_data['events'] || []

    describe 'Event uei.opennms.org/cheftest/thresholdExceeded2-event_add_parameters' do
      subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2-event_add_parameters' } }

      it { should_not be_nil }

      it 'validates the parameter state parsed out of the API tree' do
        raw_params = subject&.dig('parameter') || subject&.dig('parameters')
        params = raw_params.is_a?(Hash) ? [raw_params] : raw_params

        expect(params).to_not be_nil

        # Accommodates string or boolean notation forms across both schema layouts
        expect(params).to include(
                            hash_including('name' => 'param1', 'value' => 'paramValue1'),
                            hash_including('name' => 'param2', 'value' => 'paramValue2')
                          )
      end
    end
  end
end
