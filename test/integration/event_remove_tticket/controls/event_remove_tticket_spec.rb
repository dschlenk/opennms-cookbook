# frozen_string_literal: true

control 'event_remove_tticket' do
  title 'OpenNMS Event Trouble Ticket Removal Verification'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(tticket)) { should be_nil }
  end
end
