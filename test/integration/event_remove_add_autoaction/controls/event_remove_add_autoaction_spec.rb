# frozen_string_literal: true

control 'event_remove_add_autoaction' do
  title 'OpenNMS Event Remove and Add Autoaction Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(autoaction)) { should eq([{ 'content' => 'someaction', 'state' => 'off' }]) }
  end
end
