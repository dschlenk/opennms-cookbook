# frozen_string_literal: true

control 'event_edit_tticket' do
  title 'OpenNMS Event Trouble Ticket Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(tticket content)) { should eq 'tticketInfo' }
    its(%w(tticket state))   { should eq 'on' }
  end
end
