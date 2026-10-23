# frozen_string_literal: true

control 'event_edit_autoaction' do
  title 'OpenNMS Event Autoaction Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_autoaction', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the updated autoaction attributes' do
      expect(subject.event_data['autoaction']).to include(
                                                            hash_including('action' => 'someaction2', 'state' => 'on')
                                                         )
    end
  end
end
