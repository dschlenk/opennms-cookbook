# frozen_string_literal: true
include_recipe 'onms_lwrp_test::event'
# test update logmsg_notify
opennms_event 'change logmsg notify attr of thresholdExceeded2' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  file 'events/chef.events.xml'
  logmsg_notify false
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
