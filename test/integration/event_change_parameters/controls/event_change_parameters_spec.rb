# frozen_string_literal: true

control 'event_change_parameters' do
  title 'OpenNMS Event Parameters Modification Fallback Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }

    it 'validates the parameter fallback state based on schema capabilities' do
      params = subject.parameter

      if params.nil?
        expect(params).to be_nil
      elsif params.any? { |p| p.key?('expand') }
        expect(params).to eq([
                               { 'name' => 'param1', 'value' => 'value1' },
                               { 'name' => 'param2', 'value' => 'value2', 'expand' => false },
                             ])
      else
        expect(params).to eq([
                               { 'name' => 'param1', 'value' => 'value1' },
                               { 'name' => 'param2', 'value' => 'value2' },
                             ])
      end
    end
  end
end
