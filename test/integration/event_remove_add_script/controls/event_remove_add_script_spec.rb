# frozen_string_literal: true

control 'event_remove_add_script' do
  title 'OpenNMS Event Remove and Add Script Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_script', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the re-added script tracking configuration properties' do
      expect(subject.event_data['script']).to include(
                                                       hash_including('name' => 'anScript', 'language' => 'groovy')
                                                     )
    end
  end
end
