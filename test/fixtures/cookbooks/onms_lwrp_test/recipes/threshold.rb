# need to turn on thresholding on ICMP service first
opennms_poller_service "ICMP" do
  package_name 'example1'
  params 'rrd-repository' => '/opt/opennms/share/rrd/response', 'rrd-base-name' => 'icmp', 'ds-name' => 'icmp', 'thresholding-enabled' => 'true'
  status 'on'
  timeout 3000
  class_name 'org.opennms.netmgt.poller.monitors.IcmpMonitor'
  notifies :restart, 'service[opennms]'
end

opennms_threshd_package "cheftest" do
  filter "IPADDR != '0.0.0.0'"
  specifics ['172.17.16.1']
  include_ranges [{'begin' => '172.17.13.1', 'end' => '172.17.13.254'}, {'begin' => '172.17.20.1', 'end' => '172.17.20.254'}]
  exclude_ranges [{'begin' => '10.0.0.1', 'end' => '10.254.254.254'}]
  include_urls ['file:/opt/opennms/etc/include']
  services [{'name' => 'ICMP', 'interval' => 300000, 'status' => 'on', 'params' => {'thresholding-group' => 'cheftest'}}]
  notifies :run, 'opennms_send_event[restart_Threshd]'
end

opennms_threshold_group "cheftest" do
  rrd_repository '/opt/opennms/share/rrd/response'
end

# common options
opennms_threshold "icmp" do
  group 'cheftest'
  type 'high'
  description 'ping latency too high'
  ds_type 'if'
  value 20000.0
  rearm 18000.0
  trigger 2
  notifies :run, 'opennms_send_event[restart_Thresholds]'
end

# define events for tiggered/rearmed
opennms_event "uei.opennms.org/thresholdTest/testThresholdExceeded" do
  file "events/chef.events.xml"
  event_label "Chef defined event: testThresholdExceeded"
  descr "<p>A threshold defined by a chef recipe that tests thresholds has been exceeded.</p>"
  logmsg "Chef test threshold exceeded."
  logmsg_dest "logndisplay"
  logmsg_notify true
  severity "Minor"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
opennms_event "uei.opennms.org/thresholdTest/testThresholdRearmed" do
  file "events/chef.events.xml"
  event_label "Chef defined event: testThresholdRearmed"
  descr "<p>A threshold defined by a chef recipe that tests thresholds has been rearmed.</p>"
  logmsg "Chef test threshold rearmed."
  logmsg_dest "logndisplay"
  logmsg_notify true
  severity "Normal"
  notifies :run, 'opennms_send_event[restart_Eventd]'
end
# most  options
opennms_expression "icmp / 1000" do
  group 'cheftest'
  type 'high'
  description 'ping latency too high expression'
  ds_type 'if'
  value 20.0
  rearm 18.0
  trigger 3
  triggered_uei 'uei.opennms.org/thresholdTest/testThresholdExceeded'
  rearmed_uei 'uei.opennms.org/thresholdTest/testThresholdRearmed'
  filter_operator 'and'
  resource_filters [{'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$'}]
  notifies :run, 'opennms_send_event[restart_Thresholds]'
end
