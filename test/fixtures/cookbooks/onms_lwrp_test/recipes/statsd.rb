# all options - filter not required.
opennms_statsd_package "cheftest" do 
  filter "IPADDR != '0.0.0.0'"
end

# simplest case, but example1 exists in the  default config, has no filter,
# and is the default package used by opennms_statsd_report if none is specified.
opennms_statsd_package "emtee"

# all the things
opennms_statsd_report "cheftest_testChefReport" do
  report_name 'chefReport' # used as the report name if defined
  package_name 'cheftest'
  description 'testing report lwrp'
  schedule '0 30 2 * * ?'
  retain_interval 5184000000
  status 'off'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
  class_name 'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor'
  notifies :run, 'opennms_send_event[restart_Statsd]'
end

# minimum of the things. Although parameters isn't required by the schema it effectively is. 
opennms_statsd_report "testDefaultsReport" do
  package_name 'cheftest'
  description 'testing report lwrp defaults'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
  notifies :run, 'opennms_send_event[restart_Statsd]'
end
