# frozen_string_literal: true

control 'event_edit_tticket' do
  title 'OpenNMS Event Trouble Ticket Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_tticket', 'events/chef.events.xml') do
    it { should exist }

    it 'validates the trouble ticket information and state' do
      tticket = subject['tticket']
      expect(tticket).not_to be_nil
      expect(tticket['info']).to eq 'tticketInfo'
      expect(tticket['state']).to eq 'on'
    end
  end
end
