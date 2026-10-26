plugins = %w(opennms-plugin-provisioning-snmp-asset opennms-plugin-provisioning-snmp-hardware-inventory)
major_version = Opennms::Helpers.major(node['opennms']['version']).to_i

plugins.push 'opennms-plugin-provisioning-wsman-asset' if major_version >= 24
node.default['opennms']['plugin']['addl'] = plugins
