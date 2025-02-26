# all options
opennms_destination_path 'foo' do
  initial_delay '5s'
end
# minimal
opennms_destination_path 'bar'

# noop :create_if_missing
opennms_destination_path 'noop foo' do
  initial_delay '15s'
  action :create_if_missing
end

# op :create_if_missing
opennms_destination_path 'baz' do
  :create_if_missing
end

# update
opennms_destination_path 'update baz' do
  path_name 'baz'
  initial_delay '15s'
  action :update
end

# delete
opennms_destination_path 'delete'

opennms_destination_path 'delete delete' do
  path_name 'delete'
  action :delete
end

opennms_destination_path 'nope' do
  action :delete
end

# used to test suppression of paths without a target
opennms_destination_path '404'
# the schema requires each destination path to have at least one target, so only paths with at least one target are rendered in the config file
opennms_target 'Admin-foo' do
  target_name 'Admin'
  destination_path_name 'foo'
  commands ['javaEmail']
end

opennms_target 'Admin-bar' do
  target_name 'Admin'
  destination_path_name 'bar'
  commands ['javaPagerEmail']
end

opennms_target 'Admin-baz' do
  target_name 'Admin'
  destination_path_name 'baz'
  commands ['javaPagerEmail']
end

# noop :create_if_missing
opennms_target 'noop Admin-foo' do
  target_name 'Admin'
  destination_path_name 'foo'
  commands %w(javaEmail javaPagerEmail)
  action :create_if_missing
end

# op :create_if_missing
opennms_target 'functional admin-baz' do
  target_name 'admin'
  destination_path_name 'baz'
  auto_notify 'off'
  interval '7s'
  commands %w(javaEmail javaPagerEmail)
  action :create_if_missing
end

opennms_target 'rtc' do
  destination_path_name 'baz'
  commands ['javaPagerEmail']
end

# explicit update
opennms_target 'update rtc-baz' do
  target_name 'rtc'
  destination_path_name 'baz'
  auto_notify 'auto'
  interval '8s'
  commands %w(javaPagerEmail javaEmail)
  action :update
end

# implicit update
opennms_target 'update rtc-baz' do
  target_name 'rtc'
  destination_path_name 'baz'
  interval '9s'
end

opennms_target 'to delete' do
  target_name 'admin'
  destination_path_name 'bar'
  commands ['javaPagerEmail']
end

opennms_target 'delete to delete' do
  target_name 'admin'
  destination_path_name 'bar'
  action :delete
end

opennms_target 'delete nothing' do
  target_name 'admin'
  destination_path_name 'foo'
  action :delete
end
# escalate
opennms_target 'escalate Admin-foo' do
  target_name 'Admin'
  destination_path_name 'foo'
  commands ['javaEmail']
  type 'escalate'
end
# noop :create_if_missing
opennms_target 'escalate noop Admin-foo' do
  target_name 'Admin'
  destination_path_name 'foo'
  commands %w(javaEmail javaPagerEmail)
  type 'escalate'
  action :create_if_missing
end

# op :create_if_missing
opennms_target 'escalate functional admin-baz' do
  target_name 'admin'
  destination_path_name 'baz'
  auto_notify 'off'
  interval '7s'
  escalate_delay '9s'
  commands %w(javaEmail javaPagerEmail)
  type 'escalate'
  action :create_if_missing
end

opennms_target 'escalate rtc' do
  target_name 'rtc'
  destination_path_name 'baz'
  commands ['javaPagerEmail']
  type 'escalate'
end

# explicit update
opennms_target 'escalate update rtc-baz' do
  target_name 'rtc'
  destination_path_name 'baz'
  auto_notify 'auto'
  interval '8s'
  escalate_delay '10s'
  commands %w(javaPagerEmail javaEmail)
  type 'escalate'
  action :update
end

# implicit update
opennms_target 'escalate update rtc-baz' do
  target_name 'rtc'
  destination_path_name 'baz'
  interval '9s'
  type 'escalate'
end

opennms_target 'escalate to delete' do
  target_name 'admin'
  destination_path_name 'bar'
  commands ['javaPagerEmail']
  type 'escalate'
end

opennms_target 'delete escalate to delete' do
  target_name 'admin'
  destination_path_name 'bar'
  type 'escalate'
  action :delete
end

opennms_target 'escalate delete nothing' do
  target_name 'admin'
  destination_path_name 'foo'
  type 'escalate'
  action :delete
end
