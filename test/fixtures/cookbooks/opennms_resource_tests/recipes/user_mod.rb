include_recipe 'opennms_resource_tests::user'

# change everything about jimmy
opennms_user 'jimmy' do
  full_name 'Jimmy Jam'
  user_comments 'The Time'
  roles ['ROLE_ADMIN']
  duty_schedules []
  notifies :restart, 'service[opennms]'
end

opennms_user 'jimmy' do
  password 'one2three4'
  password_salt true
  action :set_password
end

# delete johnny
opennms_user 'johnny' do
  action :delete
end
