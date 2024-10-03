unified_mode true
use 'partial/_snmp_config'

property :port, Integer, identity: true
property :read_community, String, identity: true
property :write_community, String, identity: true
property :retry_count, Integer, identity: true
property :timeout, Integer, identity: true
property :proxy_host, String, identity: true
property :version, String, equal_to: %w(v1 v2c v3), identity: true
property :max_vars_per_pdu, Integer, identity: true
property :max_repetitions, Integer, identity: true
property :max_request_size, Integer, identity: true
property :ttl, Integer, identity: true
property :encrypted, [true, false], identity: true
property :security_name, String, identity: true
property :security_level, Integer, equal_to: [1, 2, 3], identity: true
property :auth_passphrase, String, identity: true
property :auth_protocol, String, equal_to: %w(MD5 SHA SHA-224 SHA-256 SHA-512), identity: true
property :engine_id, String, identity: true
property :context_engine_id, String, identity: true
property :context_name, String, identity: true
property :privacy_passphrase, String, identity: true
property :privacy_protocol, String, equal_to: %w(DES AES AES192 AES256), identity: true
property :enterprise_id, String, identity: true
property :location, String, identity: true
property :profile_label, String, identity: true
# [{ 'beginIP' => 'endIP'}, ... ]
property :ranges, Array
# Array of IP address strings
property :specifics, Array
# Array of IPLIKE address strings ([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)\.([0-9]{1,3}((,|-)[0-9]{1,3})*|\*)
property :ip_matches, Array

load_current_value do |new_resource|
  snmp_config = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.read("#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
  definition = snmp_config.definition(new_resource.port, new_resource.retry_count, new_resource.timeout, new_resource.read_community, new_resource.write_community, new_resource.proxy_host, new_resource.version, new_resource.max_vars_per_pdu, new_resource.max_repetitions, new_resource.max_request_size, new_resource.ttl, new_resource.encrypted, new_resource.security_name, new_resource.security_level, new_resource.auth_passphrase, new_resource.auth_protocol, new_resource.engine_id, new_resource.context_engine_id, new_resource.context_name, new_resource.privacy_passphrase, new_resource.privacy_protocol, new_resource.enterprise_id, new_resource.location, new_resource.profile_label)
  current_value_does_not_exist! if definition.nil?
  %i(port read_community write_community retry_count timeout proxy_host version max_vars_per_pdu max_repetitions max_request_size ttl encrypted security_name security_level auth_passphrase auth_protocol engine_id context_engine_id context_name privacy_passphrase privacy_protocol enterprise_id location profile_label ranges specifics ip_matches).each do |p|
    send(p, definition.send(p))
  end
end

action :add do
  converge_if_changed do
    xml_resource_init
    snmp_config = xml_resource.variables[:snmp_config]
    definition = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFileDefinition.new
    Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(definition, new_resource)
    definition.location = new_resource.location
    definition.profile_label = new_resource.profile_label
    definition.ranges = new_resource.ranges
    definition.specifics = new_resource.specifics
    definition.ip_matches = new_resource.ip_matches
    snmp_config.add_definition(definition)
  end
end

action(:create) { run_action(:add) }

action :delete do
  xml_resource_init
  snmp_config = xml_resource.variables[:snmp_config]
  definition = snmp_config.definition(new_resource.port, new_resource.retry_count, new_resource.timeout, new_resource.read_community, new_resource.write_community, new_resource.proxy_host, new_resource.version, new_resource.max_vars_per_pdu, new_resource.max_repetitions, new_resource.max_request_size, new_resource.ttl, new_resource.encrypted, new_resource.security_name, new_resource.security_level, new_resource.auth_passphrase, new_resource.auth_protocol, new_resource.engine_id, new_resource.context_engine_id, new_resource.context_name, new_resource.privacy_passphrase, new_resource.privacy_protocol, new_resource.enterprise_id, new_resource.location, new_resource.profile_label)
  converge_by("Removing SNMP config definition #{new_resource.name}") do
    snmp_config.remove_definition(definition)
  end unless definition.nil?
end
