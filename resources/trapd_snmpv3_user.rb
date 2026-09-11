unified_mode true

provides :opennms_trapd_snmpv3_user

property :security_name,
         String,
         required: true

property :engine_id,
         String

property :security_level,
         String,
         required: true,
         equal_to: %w(
           NOAUTH_NOPRIV
           AUTH_NOPRIV
           AUTH_PRIV
         )

property :auth_protocol,
         String

property :privacy_protocol,
         String

property :auth_passphrase,
         String,
         sensitive: true

property :privacy_passphrase,
         String,
         sensitive: true

action_class do
  def identity
    Opennms::Trapd::Snmpv3UserIdentity.new(
      engine_id: new_resource.engine_id,
      security_name: new_resource.security_name,
      security_level: new_resource.security_level,
      auth_protocol: new_resource.auth_protocol,
      privacy_protocol: new_resource.privacy_protocol
    )
  end

  def current_user
    Opennms::Trapd::TrapdConfig.instance_for(node)
                               .find_user(identity)
  end

  def user_payload
    identity.to_h.merge(
      {
        'authPassphrase' => new_resource.auth_passphrase,
        'privacyPassphrase' => new_resource.privacy_passphrase,
      }.compact
    )
  end

  def validate_security_configuration!
    case new_resource.security_level
    when 'NOAUTH_NOPRIV'
      raise(
        'auth_protocol may not be specified when security_level is NOAUTH_NOPRIV'
      ) if new_resource.auth_protocol

      raise(
        'auth_passphrase may not be specified when security_level is NOAUTH_NOPRIV'
      ) if new_resource.auth_passphrase

      raise(
        'privacy_protocol may not be specified when security_level is NOAUTH_NOPRIV'
      ) if new_resource.privacy_protocol

      raise(
        'privacy_passphrase may not be specified when security_level is NOAUTH_NOPRIV'
      ) if new_resource.privacy_passphrase

    when 'AUTH_NOPRIV'
      raise(
        'auth_protocol is required when security_level is AUTH_NOPRIV'
      ) unless new_resource.auth_protocol

      raise(
        'auth_passphrase is required when security_level is AUTH_NOPRIV'
      ) unless new_resource.auth_passphrase

      raise(
        'privacy_protocol may not be specified when security_level is AUTH_NOPRIV'
      ) if new_resource.privacy_protocol

      raise(
        'privacy_passphrase may not be specified when security_level is AUTH_NOPRIV'
      ) if new_resource.privacy_passphrase

    when 'AUTH_PRIV'
      raise(
        'auth_protocol is required when security_level is AUTH_PRIV'
      ) unless new_resource.auth_protocol

      raise(
        'auth_passphrase is required when security_level is AUTH_PRIV'
      ) unless new_resource.auth_passphrase

      raise(
        'privacy_protocol is required when security_level is AUTH_PRIV'
      ) unless new_resource.privacy_protocol

      raise(
        'privacy_passphrase is required when security_level is AUTH_PRIV'
      ) unless new_resource.privacy_passphrase
    end
  end
end

load_current_value do
  user = current_user

  current_value_does_not_exist! unless user

  auth_passphrase user['authPassphrase']
  privacy_passphrase user['privacyPassphrase']
end

action :create do
  validate_security_configuration!

  converge_if_changed do
    cfg = Opennms::Trapd::TrapdConfig.instance_for(node)

    cfg.add_or_update_snmpv3_user(
      user_payload
    )

    cfg.update(self)
  end
end

action :delete do
  validate_security_configuration!

  return unless current_user

  converge_by("delete trapd SNMPv3 user #{new_resource.name}") do
    cfg = Opennms::Trapd::TrapdConfig.instance_for(node)

    cfg.delete_snmpv3_user(identity)

    cfg.update(self)
  end
end
