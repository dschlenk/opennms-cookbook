# frozen_string_literal: true

control 'event_remove_add_varbindsdecode' do
  title 'OpenNMS Event Remove and Add Varbindsdecode Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_varbindsdecode', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the re-added varbind decoding configurations' do
      raw_decode = subject['varbindsdecode']
      decode_list = raw_decode.is_a?(Hash) ? [raw_decode] : raw_decode

      expect(decode_list).to include(
                               hash_including('parmid' => 'theParmId')
                             )
    end
  end
end
