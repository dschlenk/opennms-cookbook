plugins = %w(opennms-plugin-provisioning-snmp-asset opennms-plugin-provisioning-snmp-hardware-inventory)
major_version = Opennms::Helpers.major(node['opennms']['version']).to_i
if major_version >= 17
  plugins.push 'opennms-plugin-northbounder-jms'
else
  Chef::Log.warn "not pushing, isn't >= 17"
end

plugins.push 'opennms-plugin-provisioning-wsman-asset' if major_version >= 24
node.default['opennms']['plugin']['addl'] = plugins
