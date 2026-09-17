include Opennms::Cookbook::Trapd::ConfigTemplate
unified_mode true

provides :opennms_trapd_snmpv3_user

property :security_name, String, required: true, identity: true
property :engine_id, String, identity: true
property :security_level, String, required: true, equal_to: %w(NOAUTH_NOPRIV AUTH_NOPRIV AUTH_PRIV), identity: true
property :auth_protocol, String, equal_to: %w(MD5 SHA SHA-224 SHA-256 SHA-512), identity: true
property :auth_passphrase, String, sensitive: true, callbacks: { 'should be a String that is at least 8 characters long' => ->(p) { p.nil? || p.length >= 8 } }
property :privacy_protocol, String, equal_to: %w(DES AES AES192 AES256), identity: true
property :privacy_passphrase, String, sensitive: true, callbacks: { 'should be a String that is at least 8 characters long' => ->(p) { p.nil? || p.length >= 8 } }

action_class do
  include Opennms::Cookbook::Trapd::ConfigTemplate
  def validate_security_configuration!
    case new_resource.security_level
    when 'NOAUTH_NOPRIV'
      raise(
        'auth_protocol, auth_passphrase, privacy_protocol, privacy_passphrase may not be specified when security_level is NOAUTH_NOPRIV'
      ) if new_resource.auth_protocol || new_resource.auth_passphrase || new_resource.privacy_protocol || new_resource.privacy_passphrase
    when 'AUTH_NOPRIV'
      raise(
        'auth_protocol, auth_passphrase are required when security_level is AUTH_NOPRIV'
      ) if !new_resource.auth_protocol || !new_resource.auth_passphrase

      raise(
        'privacy_protocol, privacy_passphrase may not be specified when security_level is AUTH_NOPRIV'
      ) if new_resource.privacy_protocol || new_resource.privacy_passphrase

    when 'AUTH_PRIV'
      raise(
        'auth_protocol, auth_passphrase, privacy_protocol, privacy_passphrase are required when security_level is AUTH_PRIV'
      ) if !new_resource.auth_protocol || !new_resource.auth_passphrase || !new_resource.privacy_protocol || !new_resource.privacy_passphrase
    end
  end
end

load_current_value do
  # load current config
  r = trapd_resource
  if r.nil?
    ro_trapd_resource_init
    r = ro_trapd_resource
  end
  config = config_from_resource(r)
  # find a user in the config that matches the identity of the new resource
  user = config.user_for_identity(
    engine_id,
    security_name,
    security_level,
    auth_protocol,
    privacy_protocol
  )

  current_value_does_not_exist! unless user

  auth_passphrase user.auth_passphrase
  privacy_passphrase user.privacy_passphrase
end

action :create do
  validate_security_configuration!

  converge_if_changed do
    trapd_resource_init
    r = trapd_resource
    cfg = config_from_resource(r)
    u = cfg.user_for_identity(new_resource.engine_id, new_resource.security_name, new_resource.security_level, new_resource.auth_protocol, new_resource.privacy_protocol)
    if u
      u['authPassphrase'] = new_resource.auth_passphrase if new_resource.auth_passphrase
      u['privacyPassphrase'] = new_resource.privacy_passphrase if new_resource.privacy_passphrase
    else
      cfg.add_snmpv3_user(
        Opennms::Cookbook::Trapd::Snmpv3User.new(
          engine_id: new_resource.engine_id,
          security_name: new_resource.security_name,
          security_level: Opennms::Cookbook::Trapd::Config::SECURITY_LEVELS[new_resource.security_level],
          auth_protocol: new_resource.auth_protocol,
          auth_passphrase: new_resource.auth_passphrase,
          privacy_protocol: new_resource.privacy_protocol,
          privacy_passphrase: new_resource.privacy_passphrase
        )
      )
    end
  end
end

action :delete do
  validate_security_configuration!

  r = trapd_resource
  if r.nil?
    ro_trapd_resource_init
    r = ro_trapd_resource
  end
  cfg = config_from_resource(r)
  u = cfg.user_for_identity(new_resource.engine_id, new_resource.security_name, new_resource.security_level, new_resource.auth_protocol, new_resource.privacy_protocol)
  if u
    converge_by("delete trapd SNMPv3 user #{new_resource.name}") do
      trapd_resource_init
      r = trapd_resource
      cfg = config_from_resource(r)
      u = cfg.user_for_identity(new_resource.engine_id, new_resource.security_name, new_resource.security_level, new_resource.auth_protocol, new_resource.privacy_protocol)
      cfg.remove_snmpv3_user(u)
    end
  end
end
