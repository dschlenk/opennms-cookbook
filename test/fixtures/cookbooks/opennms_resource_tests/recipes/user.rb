# frozen_string_literal: true
log 'Start OpenNMS to perform ReST operations.' do
  notifies :start, 'service[opennms]', :immediately
end

mv = node['opennms']['version'].to_i
if node['platform_version'].to_i == 6
  if mv == 24 || mv == 25
    log 'restart postgresql-9.6 because opennms does not start cleanly for some reason' do
      notifies :restart, 'service[postgresql-9.6]', :immediately
    end
    log 'restart OpenNMS again because bugs in 24' do
      notifies :restart, 'service[opennms]', :immediately
    end
  end
end

# all options except duty schedules. Note the password is pre-hashed and we
# tell opennms to restart. Due to NMS-6469 a restart is required before the
# new users are available.
opennms_user 'jimmy' do
  full_name 'Jimmy John'
  user_comments 'Sandwiches'
  password '6D639656F5EAC2E799D32870DD86046D'
  password_salt false
  notifies :restart, 'service[opennms]'
end

# minimal - password is required
opennms_user 'johnny' do
  password '6D639656F5EAC2E799D32870DD86046D'
end
