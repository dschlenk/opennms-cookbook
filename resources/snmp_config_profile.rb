use 'partial/_snmp_config'

property :label, String, name_property: true
property :filter, String

load_current_value do |new_resource|
  snmp_config = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.read("#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
  profile = snmp_config.profile(new_resource.label)
  current_value_does_not_exist! if profile.nil?
  %i(port read_community write_community retry_count timeout proxy_host version max_vars_per_pdu max_repetitions max_request_size ttl encrypted security_name security_level auth_passphrase auth_protocol engine_id context_engine_id context_name privacy_passphrase privacy_protocol enterprise_id filter).each do |p|
    send(p, profile.send(p))
  end
end

action :add do
  converge_if_changed do
    xml_resource_init
    snmp_config = xml_resource.variables[:snmp_config]
    profile = Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFileProfile.new
    Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(profile, new_resource)
    profile.label = new_resource.label
    profile.filter = new_resource.filter
    snmp_config.add_profile(profile)
  end
end

action(:create) { run_action(:add) }

action :delete do
  xml_resource_init
  snmp_config = xml_resource.variables[:snmp_config]
  profile = snmp_config.profile(new_resource.label)
  converge_by("Removing SNMP config profile #{new_resource.name}") do
    snmp_config.remove_profile(profile)
  end unless profile.nil?
end
