include_recipe 'opennms_resource_tests::event'

opennms_event 'edit forward ' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_forward'
  file 'events/chef.events.xml'
  forward [{ 'info' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmpudp' }]
  position 'top'
  action :create
  notifies :run, 'ruby_block[EXECUTE BULK OPENNMS UPLOAD]', :delayed
  notifies :run, 'ruby_block[EXECUTE BULK OPENNMS UPLOAD]', :delayed
end
