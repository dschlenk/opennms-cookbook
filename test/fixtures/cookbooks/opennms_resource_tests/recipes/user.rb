# all options except duty schedules. Passwords are required for new resources
# and should be retrieved from a vault or other secure location.
opennms_user 'jimmy' do
  full_name 'Jimmy John'
  email 'person@example.com'
  user_comments 'Sandwiches'
  password chef_vault_item('creds', 'users')['jimmy']['password']
  password_salt true
  roles %w(ROLE_ADMIN ROLE_ASSET_EDITOR ROLE_FILESYSTEM_EDITOR ROLE_DELEGATE ROLE_DEVICE_CONFIG_BACKUP ROLE_JMX ROLE_MINION ROLE_READONLY ROLE_USER ROLE_DASHBOARD ROLE_REST ROLE_RTC ROLE_MOBILE ROLE_FLOW_MANAGER ROLE_REPORT_DESIGNER ROLE_PROVISION)
  duty_schedules %w(Mo1-300 TuWe301-2359)
end

# minimal - password is required
opennms_user 'johnny' do
  password chef_vault_item('creds', 'users')['johnny']['password']
end
