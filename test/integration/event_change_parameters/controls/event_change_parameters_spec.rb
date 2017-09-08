# frozen_string_literal: true
control 'event_change_parameters' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('parameters') { should eq([{ 'name' => 'param1', 'value' => 'value1' }, { 'name' => 'param2', 'value' => 'value2', 'expand' => false }]) }
  end
end
