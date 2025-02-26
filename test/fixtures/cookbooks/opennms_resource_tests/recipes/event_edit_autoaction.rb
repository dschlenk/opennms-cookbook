include_recipe 'opennms_resource_tests::event'
opennms_event 'edit autoaction' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  file 'events/chef.events.xml'
  autoaction [{ 'action' => 'someaction2', 'state' => 'on' }]
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
