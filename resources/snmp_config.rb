use 'partial/_snmp_config'

unified_mode true

include Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate
include Opennms::Rbac
load_current_value do |new_resource|
  if snmp_config_v36?
    raise Chef::Exceptions::ValidationFailed, "opennms_snmp_config[#{new_resource.name}]: encrypted is not supported on OpenNMS 36, the snmp config is stored in the database and passphrases are never stored encrypted" if new_resource.encrypted
    snmp_config = snmp_config_file
  else
    r = xml_resource
    if r.nil?
      ro_xml_resource_init
      r = ro_xml_resource
    end
    snmp_config = r.variables[:snmp_config]
  end
  %i(port read_community write_community retry_count timeout proxy_host version max_vars_per_pdu max_repetitions max_request_size ttl encrypted security_name security_level auth_passphrase auth_protocol engine_id context_engine_id context_name privacy_passphrase privacy_protocol enterprise_id).each do |p|
    send(p, snmp_config.send(p)) # should have the right type already, no need to cast
  end
end

action :create do
  converge_if_changed do
    xml_resource_init
    if snmp_config_v36?
      snmp_config_update_file do |snmp_config|
        Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(snmp_config, new_resource)
      end
    else
      snmp_config = xml_resource.variables[:snmp_config]
      Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(snmp_config, new_resource)
    end
  end
end
