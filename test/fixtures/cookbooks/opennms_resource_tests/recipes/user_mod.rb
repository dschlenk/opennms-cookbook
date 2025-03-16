include_recipe 'opennms_resource_tests::user'

# change everything about jimmy
opennms_user 'jimmy' do
  full_name 'Jimmy Jam'
  user_comments 'The Time'
  roles ['ROLE_ADMIN']
  duty_schedules []
end

opennms_user 'jimmy' do
  password 'one2three4'
  password_salt true
  action :set_password
end

opennms_user 'update nothing about johnny' do
  user_id 'johnny'
  action :update
end

# delete johnny
opennms_user 'delete johnny' do
  user_id 'johnny'
  action :delete
end

opennms_user 'update admin' do
  user_id 'admin'
  full_name nil
  roles nil
  password 'admin'
end
