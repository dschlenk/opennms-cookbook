opennms_trapd_config 'default' do
  batch_interval 200
  batch_size 500
  include_raw_message true
  new_suspect_on_trap false
  queue_size 5000
  snmp_trap_address '0.0.0.0'
  snmp_trap_port 1162
  threads 8
  use_address_from_varbind true
end

opennms_trapd_snmpv3_user 'readonly user' do
  security_name 'readonly'
  security_level 'NOAUTH_NOPRIV'
end

opennms_trapd_snmpv3_user 'auth user' do
  security_name 'monitor'
  security_level 'AUTH_NOPRIV'
  auth_protocol 'SHA'
  auth_passphrase 'authsecret'
end

opennms_trapd_snmpv3_user 'priv user without engine id' do
  security_name 'trapuser'
  security_level 'AUTH_PRIV'
  auth_protocol 'SHA'
  auth_passphrase 'authsecret'
  privacy_protocol 'AES'
  privacy_passphrase 'privsecret'
end

opennms_trapd_snmpv3_user 'priv user with engine id' do
  security_name 'trapuser'
  engine_id '8000000001020304'
  security_level 'AUTH_PRIV'
  auth_protocol 'SHA'
  auth_passphrase 'engineauthsecret'
  privacy_protocol 'AES'
  privacy_passphrase 'engineprivsecret'
end
