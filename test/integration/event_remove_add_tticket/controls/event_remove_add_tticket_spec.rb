# frozen_string_literal: true

control 'event_remove_add_tticket' do
  title 'OpenNMS Event Remove Add Tticket Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_tticket', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the expected tticket configuration' do
      expect(subject['tticket']).to eq('info' => 'tticketInfo', 'state' => 'on')
    end
  end
end
