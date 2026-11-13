# frozen_string_literal: true

control 'event_remove_add_script' do
  title 'OpenNMS Event Remove and Add Script Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_script', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the re-added script configurations' do
      raw_script = subject['script']
      script_list = raw_script.is_a?(Hash) ? [raw_script] : raw_script

      expect(script_list).to include(
                               hash_including('name' => 'anScript', 'language' => 'groovy')
                             )
    end
  end
end
