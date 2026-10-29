use 'partial/_snmp_config'

unified_mode true

property :label, String, name_property: true
property :filter, String

include Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate
include Opennms::Rbac

load_current_value do |new_resource|
  if snmp_config_v36?
    raise Chef::Exceptions::ValidationFailed, "opennms_snmp_config_profile[#{new_resource.name}]: encrypted is not supported on OpenNMS 36, the snmp config is stored in the database and passphrases are never stored encrypted" if new_resource.encrypted
    snmp_config = snmp_config_file
  else
    r = xml_resource
    if r.nil?
      ro_xml_resource_init
      r = ro_xml_resource
    end
    snmp_config = r.variables[:snmp_config]
  end
  profile = snmp_config.profile(new_resource.label)
  current_value_does_not_exist! if profile.nil?
  %i(port read_community write_community retry_count timeout proxy_host version max_vars_per_pdu max_repetitions max_request_size ttl encrypted security_name security_level auth_passphrase auth_protocol engine_id context_engine_id context_name privacy_passphrase privacy_protocol enterprise_id filter).each do |p|
    send(p, profile.send(p))
  end
end

action :add do
  converge_if_changed do
    xml_resource_init
    if snmp_config_v36?
      snmp_config_update_file do |snmp_config|
        profile = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFileProfile.new
        Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(profile, new_resource)
        profile.label = new_resource.label
        profile.filter = new_resource.filter
        snmp_config.add_profile(profile)
      end
    else
      snmp_config = xml_resource.variables[:snmp_config]
      profile = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFileProfile.new
      Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(profile, new_resource)
      profile.label = new_resource.label
      profile.filter = new_resource.filter
      snmp_config.add_profile(profile)
    end
  end
end

action(:create) { run_action(:add) }

action :delete do
  snmp_config = if snmp_config_v36?
                  snmp_config_file
                else
                  xml_resource_init
                  xml_resource.variables[:snmp_config]
                end
  profile = snmp_config.profile(new_resource.label)
  unless profile.nil?
    converge_by("Removing SNMP config profile #{new_resource.name}") do
      if snmp_config_v36?
        xml_resource_init
        snmp_config_update_file do |snmp_config_file|
          snmp_config_file.remove_profile(profile)
        end
      else
        snmp_config.remove_profile(profile)
      end
    end
  end
end
