# frozen_string_literal: true

control 'event_remove_tticket' do
  title 'OpenNMS Event Trouble Ticket Removal Verification'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_tticket', 'events/chef.events.xml') do
    it { should exist }
    its('tticket') { should be_nil }
  end
end
