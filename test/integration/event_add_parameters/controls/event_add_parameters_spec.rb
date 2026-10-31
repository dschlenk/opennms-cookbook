# frozen_string_literal: true

control 'event_add_parameters' do
  title 'OpenNMS Event Parameters Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_add_parameters', 'events/chef.events.xml') do

    it 'contains the updated event parameters configuration' do
      expect(subject).to_not be_nil
      raw_params = subject['parameter'] || subject['parameters']
      params = raw_params.is_a?(Hash) ? [raw_params] : Array(raw_params)

      expect(params).to include(
                          hash_including('name' => 'param1', 'value' => 'paramValue1'),
                          hash_including('name' => 'param2', 'value' => 'paramValue2')
                        )
    end
  end
end
