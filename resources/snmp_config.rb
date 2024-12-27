use 'partial/_snmp_config'

include Opennms::Cookbook::ConfigHelpers::SnmpConfigTemplate
load_current_value do |_new_resource|
  r = xml_resource
  snmp_config = if r.nil?
                  Opennms::Cookbook::ConfigHelpers::SnmpConfig::SnmpConfigFile.read("#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
                else
                  r.variables[:snmp_config]
                end
  %i(port read_community write_community retry_count timeout proxy_host version max_vars_per_pdu max_repetitions max_request_size ttl encrypted security_name security_level auth_passphrase auth_protocol engine_id context_engine_id context_name privacy_passphrase privacy_protocol enterprise_id).each do |p|
    send(p, snmp_config.send(p)) # should have the right type already, no need to cast
  end
end

action :create do
  converge_if_changed do
    xml_resource_init
    snmp_config = xml_resource.variables[:snmp_config]
    Opennms::Cookbook::ConfigHelpers::SnmpConfig::Helper.attributes_from_properties(snmp_config, new_resource)
  end
end

action :create_if_missing do
  unless ::File.exist?("#{node['opennms']['conf']['home']}/etc/snmp-config.xml")
    run_action(:create)
  end
end
