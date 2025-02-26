unified_mode true

property :port, Integer
property :read_community, String
property :write_community, String
property :retry_count, Integer
property :timeout, Integer
property :proxy_host, String
property :version, String, equal_to: %w(v1 v2c v3)
property :max_vars_per_pdu, Integer
property :max_repetitions, Integer
property :max_request_size, Integer
property :ttl, Integer
property :encrypted, [true, false]
property :security_name, String
property :security_level, Integer, equal_to: [1, 2, 3]
property :auth_passphrase, String
property :auth_protocol, String, equal_to: %w(MD5 SHA SHA-224 SHA-256 SHA-512)
property :engine_id, String
property :context_engine_id, String
property :context_name, String
property :privacy_passphrase, String
property :privacy_protocol, String, equal_to: %w(DES AES AES192 AES256)
property :enterprise_id, String

action_class do
  include Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate
end
