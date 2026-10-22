# frozen_string_literal: true

control 'event_edit_operinstruct' do
  title 'OpenNMS Event Operinstruct Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(operinstruct)) { should eq 'the operinstructed' }
  end
end
