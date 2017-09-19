# frozen_string_literal: true
control 'event_remove_add_autoaction' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('autoaction') { should eq([{ 'action' => 'someaction', 'state' => 'off' }]) }
  end
end
