# all properties
opennms_notification_command 'wallHost' do
  execute '/usr/bin/wall'
  contact_type 'wall'
  comment 'wall the hostname'
  binary true
  arguments [{ 'streamed' => false, 'switch' => '-tm' }]
  service_registry false
end

# minimal properties
opennms_notification_command 'minimal' do
  execute '/bin/true'
end

opennms_notification_command 'to update' do
  execute '/bin/true'
end

opennms_notification_command 'update to update' do
  command_name 'to update'
  execute '/bin/sh'
  comment 'testing update'
  binary false
  service_registry false
  contact_type 'fax'
  arguments [{ 'streamed' => false, 'switch' => '-tm' }]
  action :update
end

opennms_notification_command 'testing noop create_if_missing' do
  command_name 'wallHost'
  execute '/usr/bin/walls'
  contact_type 'walls'
  comment 'walls the hostname'
  binary false
  arguments [{ 'streamed' => true, 'switch' => '-tmz', 'substitution' => 'atonement' }]
  service_registry false
  action :create_if_missing
end

opennms_notification_command 'testing functional create_if_missing' do
  command_name 'create_if_missing'
  execute '/bin/false'
  action :create_if_missing
end

opennms_notification_command 'delete' do
  execute '/usr/bin/env'
end

opennms_notification_command 'delete delete' do
  command_name 'delete'
  action :delete
end

opennms_notification_command 'delete nonexistent' do
  command_name 'foo'
  action :delete
end

# now let's use it in a destination path target
opennms_destination_path 'wibble'
opennms_target 'Admin_wibble_wallHost' do
  target_name 'Admin'
  destination_path_name 'wibble'
  commands ['wallHost']
end

# and as an escalation target on the default destination path
# (this also demos all the options available in opennms_target)
opennms_target 'Admin_Email_Admin_wallHost' do
  target_name 'Admin'
  destination_path_name 'Email-Admin'
  commands ['wallHost']
  auto_notify 'on'
  interval '1s'
  type 'escalate'
  escalate_delay '30s'
end
