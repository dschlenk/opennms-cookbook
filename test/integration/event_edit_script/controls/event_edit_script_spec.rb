# frozen_string_literal: true

control 'event_edit_script' do
  title 'OpenNMS Event Script Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_script', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the updated script tracking runtime environment properties' do
      expect(subject.event_data['script']).to include(
                                                hash_including('name' => 'anScript', 'language' => 'groovy')
                                              )
    end
  end
end
