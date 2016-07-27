# all options - only comment and arguments are optional although binary defaults to true if not defined. 
opennms_notification_command "wallHost" do
  execute "/usr/bin/wall"
  contact_type 'wall'
  comment "wall the hostname"
  binary true
  arguments [{'streamed' => false, 'switch' => '-tm'}]
  notifies :run, 'opennms_send_event[restart_Notifd]'
end

# now let's use it in a destination path target
opennms_destination_path "wibble" 
opennms_target "Admin_wibble_wallHost" do
  target_name "Admin"
  destination_path_name "wibble"
  commands ['wallHost']
end

# and as an escalation target on the default destination path
# (this also demos all the options available in opennms_target)
opennms_target "Admin_Email_Admin_wallHost" do
  target_name "Admin"
  destination_path_name "Email-Admin"
  commands ["wallHost"]
  auto_notify "on"
  interval "1s"
  type "escalate"
  escalate_delay "30s"
end

