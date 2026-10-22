# frozen_string_literal: true

control 'event_edit_operinstruct' do
  title 'OpenNMS Event Operinstruct Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('operinstruct') { should eq 'the operinstructed' }
  end
end
