# frozen_string_literal: true

control 'event_add_parameters' do
  title 'OpenNMS Event Parameters Addition Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_add_parameters', 'events/chef.events.xml') do
    it 'verifies that the event resource is present' do
      expect(subject).to_not be_nil
    end

    it 'validates the added parameters based on schema capabilities' do
      raw_params = subject['parameter']
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
