# most options
opennms_notification 'exampleDown' do
  status 'on'
  writeable 'yes'
  uei 'uei.opennms.org/example/exampleDown'
  description 'An example of a down type event notification.'
  rule "IPADDR != '0.0.0.0'"
  destination_path 'Email-Admin' # must match an existing destination path name
  text_message 'Your service is bad and you should feel bad.'
  subject 'Bad service.'
  numeric_message '31337'
  event_severity 'Major'
  # used by the notificationCommands.xml command as a switch. Must exist in the command to be used here otherwise fail.
  parameters(
    '-subject' => 'EMERGENCY'
  )
  vbname 'snmpifname'
  vbvalue 'eth0'
end

# minimal options
opennms_notification 'example2Broken' do
  status 'on'
  uei 'example2/exampleBroken'
  destination_path 'Email-Admin'
  text_message 'broken'
end

opennms_notification 'something2Update' do
  status 'on'
  uei 'notificationUpdated'
  destination_path 'Email-Admin'
  text_message 'notification updated'
  parameters(
    '-subject' => 'EMERGENCY'
  )
end

opennms_notification 'update something2Update' do
  notification_name 'something2Update'
  status 'off'
  uei 'notifUpdated'
  rule "IPADDR != '0.0.0.1'"
  strict_rule true
  description 'boop'
  text_message 'updated notification'
  parameters({})
  vbname 'snmpifdescr'
  vbvalue '3Com 905B Fast Ethernet'
end

opennms_notification 'delete' do
  status 'on'
  uei 'delete'
  text_message 'delete'
  destination_path 'Email-Admin'
end

opennms_notification 'delete delete' do
  notification_name 'delete'
  status 'off'
  uei 'example2/exampleBroken'
  destination_path 'Email-Admin'
  text_message 'broken'
  action :delete
end

opennms_notification 'delete nothing' do
  action :delete
end

opennms_notification 'actionable create_if_missing' do
  status 'on'
  uei 'createIfMissing'
  destination_path 'Email-Admin'
  text_message 'create_if_missing'
  action :create_if_missing
end

opennms_notification 'noop create_if_missing' do
  notification_name 'example2Broken'
  status 'off'
  uei 'example2/exampleBrokenNoop'
  destination_path 'Email-Admin'
  text_message 'brokener'
  action :create_if_missing
end
