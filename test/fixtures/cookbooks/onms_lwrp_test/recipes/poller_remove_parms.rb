# frozen_string_literal: true
include_recipe 'onms_lwrp_test::poller'

opennms_poller_service 'change class ICMPBar7' do
  service_name 'ICMPBar7'
  package_name 'bar'
  user_defined true
  interval 600_000
  status 'off'
  timeout 5000
  parameters false
  class_name 'org.opennms.netmgt.poller.monitors.SnmpMonitor'
end
