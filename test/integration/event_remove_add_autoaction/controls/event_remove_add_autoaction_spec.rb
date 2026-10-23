# frozen_string_literal: true

control 'event_remove_add_autoaction' do
  title 'OpenNMS Event Remove and Add Autoaction Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_autoaction', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the re-added autoaction configuration elements' do
      expect(subject.event_data['autoaction']).to include(
                                                           hash_including('action' => 'someaction', 'state' => 'off')
                                                         )
    end
  end
end
