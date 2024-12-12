# typical usage
opennms_group 'nerds' do
  comments 'pocket protectors and such'
  users ['admin']
  duty_schedules ['MoTuWeThFrSaSu800-1700']
end

opennms_group 'minimal' do
  users ['admin']
end

opennms_group 'update' do
  users ['admin']
end

opennms_group 'update update' do
  group_name 'update'
  users %w(admin rtc)
  comments 'barf'
  duty_schedules ['MoTuWeThFrSaSu800-1700']
  action :update
end

opennms_group 'no update' do
  group_name 'update'
  duty_schedules %w(MoTuWeThFrSaSu800-1700 MoTuWeThFrSaSu1701-1702)
  action :create_if_missing
end

opennms_group 'create_delete' do
  users ['admin']
end

opennms_group 'delete create_delete' do
  group_name 'create_delete'
  action :delete
end

opennms_group 'delete nonexist' do
  group_name 'foo'
  action :delete
end
