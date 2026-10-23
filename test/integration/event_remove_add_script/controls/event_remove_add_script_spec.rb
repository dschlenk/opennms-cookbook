# frozen_string_literal: true

control 'event_remove_add_script' do
  title 'OpenNMS Event Remove and Add Trouble Ticket Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_script', 'events/chef.events.xml') do
    it { should exist }
    its('tticket.content') { should eq 'tticketInfo' }
    its('tticket.state')   { should eq 'on' }
  end
end
