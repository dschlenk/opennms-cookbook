# frozen_string_literal: true

control 'event_remove_add_varbindsdecode' do
  title 'OpenNMS Event Remove and Add Varbindsdecode Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_varbindsdecode', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the re-added varbind decoding configurations' do
      expect(subject.event_data['varbindsdecode']).to include(
                                                               hash_including('parmid' => 'theParmId')
                                                             )
    end
  end
end
