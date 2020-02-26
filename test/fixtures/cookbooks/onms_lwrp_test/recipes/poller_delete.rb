# frozen_string_literal: true
include_recipe 'onms_lwrp_test::poller'
opennms_poller_service 'delete SNMPBar2' do
  service_name 'SNMPBar2'
  package_name 'bar'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
  action :delete
end

opennms_poller_service "delete 'SNMPBar 2'" do
  service_name 'SNMPBar 2'
  package_name 'bar'
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
  action :delete
end
