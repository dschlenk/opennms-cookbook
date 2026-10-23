# frozen_string_literal: true

control 'event_edit_forward' do
  title 'OpenNMS Event Forward Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_forward', 'events/chef.events.xml') do
    it { should exist }

    it 'contains the updated forward configurations' do
      expect(subject.event_data['forward']).to include(
                                                        hash_including('info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmpudp')
                                                      )
    end
  end
end
