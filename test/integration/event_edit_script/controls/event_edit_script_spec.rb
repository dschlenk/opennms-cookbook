# frozen_string_literal: true

control 'event_edit_script' do
  title 'OpenNMS Event Script Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_script', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the updated script tracking runtime environment properties' do
      raw_script = subject['script']
      script_list = raw_script.is_a?(Hash) ? [raw_script] : raw_script

      expect(script_list).to include(
                               hash_including('name' => 'anScript', 'language' => 'beanshell')
                             )
    end
  end
end
