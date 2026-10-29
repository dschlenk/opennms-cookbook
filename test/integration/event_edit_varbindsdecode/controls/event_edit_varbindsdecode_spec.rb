# frozen_string_literal: true

control 'event_edit_varbindsdecode' do
  title 'OpenNMS Event Varbindsdecode Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_varbindsdecode', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the updated varbind decoding configurations' do
      expect(subject.event_data['varbindsdecode']).to include(
                                                               hash_including('parmid' => 'theParmIds')
                                                             )
    end
  end
end
