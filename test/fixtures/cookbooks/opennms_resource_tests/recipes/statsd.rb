# all options - filter not required.
opennms_statsd_package 'cheftest' do
  filter "IPADDR != '0.0.0.0'"
end

# simplest case, but example1 exists in the  default config, has no filter,
# and is the default package used by opennms_statsd_report if none is specified.
opennms_statsd_package 'emtee'

opennms_statsd_package 'changeme'

opennms_statsd_package 'update changeme' do
  package_name 'changeme'
  filter "IPADDR != '1.1.1.1'"
  action :update
end

opennms_statsd_package 'deleteme'

opennms_statsd_package 'deleteme' do
  action :delete
end

opennms_statsd_package 'ifmissing' do
  filter "IPADDR != '127.0.0.1'"
end

opennms_statsd_package 'noop ifmissing' do
  filter "IPADDR != '0.0.0.0'"
  action :create_if_missing
end

# all the things
opennms_statsd_report 'cheftest_testChefReport' do
  report_name 'chefReport' # used as the report name if defined
  package_name 'cheftest'
  description 'testing report lwrp'
  schedule '0 30 2 * * ?'
  retain_interval 5_184_000_000
  status 'off'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
  class_name 'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor'
end

# minimum of the things to produce something useful. Although parameters isn't required by the schema, both currently available implementations require some parameters
opennms_statsd_report 'testDefaultsReport' do
  package_name 'cheftest'
  description 'testing report lwrp defaults'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
end

opennms_statsd_report 'foo' do
  package_name 'cheftest'
  description 'report to test updates with'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
end

opennms_statsd_report 'update foo' do
  report_name 'foo'
  package_name 'cheftest'
  description 'report to test updates withh'
  schedule '1 31 3 * * ?'
  retain_interval 4_073_999_999
  status 'off'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
  class_name 'org.opennms.netmgt.dao.support.BottomNAttributeStatisticVisitor'
  action :update
end

opennms_statsd_report 'bar' do
  package_name 'cheftest'
  description 'report to test :create_if_missing with'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
end

opennms_statsd_report 'noop bar' do
  report_name 'bar'
  package_name 'cheftest'
  description 'report to test create_if_missing with'
  schedule '1 31 3 * * ?'
  retain_interval 4_073_999_999
  status 'off'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
  action :create_if_missing
end

opennms_statsd_report 'baz' do
  package_name 'cheftest'
  description 'report to test delete with'
  schedule '1 31 3 * * ?'
  retain_interval 4_073_999_999
  status 'off'
  parameters 'count' => '20', 'consolidationFunction' => 'AVERAGE', 'relativeTime' => 'YESTERDAY', 'resourceTypeMatch' => 'interfaceSnmp', 'attributeMatch' => 'ifOutOctets'
end

opennms_statsd_report 'delete baz' do
  report_name 'baz'
  package_name 'cheftest'
  action :delete
end

opennms_statsd_report 'delete a non-existant report in a non-existant package' do
  report_name 'null'
  package_name 'nil'
  action :delete
end

opennms_statsd_report 'delete a non-existant report in an existing package' do
  report_name 'null'
  package_name 'cheftest'
  action :delete
end
