# frozen_string_literal: true

control 'event_edit_autoaction' do
  title 'OpenNMS Event Autoaction Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(autoaction)) { should eq([{ 'content' => 'someaction2', 'state' => 'on' }]) }
  end
end
