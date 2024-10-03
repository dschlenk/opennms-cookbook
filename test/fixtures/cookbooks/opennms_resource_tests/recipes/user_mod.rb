include_recipe 'opennms_resource_tests::user'

# change everything about jimmy
opennms_user 'jimmy' do
  full_name 'Jimmy Jam'
  user_comments 'The Time'
  password 'gU2wmSW7k9v1xg4/MrAsaI+VyddBAhJJt4zPX5SGG0BK+qiASGnJsqM8JOug/aEL'
  password_salt true
  notifies :restart, 'service[opennms]'
end

# give the admin role to johnny (should replace ROLE_USER)
# NOTE: unlike some other resources, you need to provide all the details you want preserved in resources that result in changes
# as we send a POST to the API, not a PUT.
opennms_user 'johnny' do
  password '6D639656F5EAC2E799D32870DD86046D'
  roles ['ROLE_ADMIN']
end
