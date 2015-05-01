log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end

# all options except duty schedules. Note the password is pre-hashed and we 
# tell opennms to restart. Due to NMS-6469 a restart is required before the 
# new users are available. 
opennms_user "jimmy" do 
  full_name "Jimmy John"
  user_comments "Sandwiches"
  password "6D639656F5EAC2E799D32870DD86046D"
  password_salt false
  notifies :restart, 'service[opennms]'
end

# minimal
opennms_user "johnny" 
