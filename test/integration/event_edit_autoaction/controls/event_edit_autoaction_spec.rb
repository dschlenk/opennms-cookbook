# frozen_string_literal: true

control 'event_edit_autoaction' do
  title 'OpenNMS Event Autoaction Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_autoaction', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the correct autoaction configurations' do
      raw_actions = subject['autoaction']
      actions = raw_actions.is_a?(Hash) ? [raw_actions] : raw_actions

      expect(actions).to eq([
                              { 'action' => 'someaction2', 'state' => 'on' },
                            ])
    end
  end
end
