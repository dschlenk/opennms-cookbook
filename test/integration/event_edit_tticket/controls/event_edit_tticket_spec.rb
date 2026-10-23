# frozen_string_literal: true

control 'event_edit_tticket' do
  title 'OpenNMS Event Trouble Ticket Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_edit_tticket', 'events/chef.events.xml') do
    it { should exist }
    its('tticket.info')  { should eq 'tticketInfo' }
    its('tticket.state') { should eq 'on' }
  end
end
