# most options
opennms_notification "exampleDown" do
  status "on"
  writeable "yes"
  uei "uei.opennms.org/example/exampleDown"
  description "An example of a down type event notification."
  rule "IPADDR != '0.0.0.0'"
  destination_path 'Email-Admin' # must match an existing destination path name
  text_message "Your service is bad and you should feel bad."
  subject "Bad service."
  numeric_message "31337"
  event_severity "Major"
#  params 'key' => 'value' - used by the notificationCommands.xml command as a switch. Must exist in the command to be used here otherwise fail.
  vbname 'snmpifname'
  vbvalue 'eth0'  
  notifies :run, 'opennms_send_event[restart_Notifd]'
end

# minimal options
opennms_notification "example2Broken" do
  status "on"
  uei "example2/exampleBroken"
  destination_path 'Email-Admin'
  text_message 'broken'
end
