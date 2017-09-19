# frozen_string_literal: true
control 'event_remove_add_alarm_data' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml', [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]) do
    it { should exist }
    its('alarm_data') { should eq({ 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false }) }
  end
end
