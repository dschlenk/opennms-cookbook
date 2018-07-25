# frozen_string_literal: true
include_recipe 'onms_lwrp_test::snmp_config_definition'
# this will delete the existing definition from the standard test
opennms_snmp_config_definition 'update_v1v2c_typical' do
  read_community 'public'
  version 'v2c'
  action :delete
  notifies :run, 'opennms_send_event[activate_snmp-config.xml]'
end
