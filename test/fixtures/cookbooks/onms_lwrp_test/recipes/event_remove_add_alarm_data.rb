# frozen_string_literal: true
include_recipe 'onms_lwrp_test::event_remove_alarm_data'
# test add alarm_data
opennms_event 'add alarm-data back to TE2' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  file 'events/chef.events.xml'
  alarm_data 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
