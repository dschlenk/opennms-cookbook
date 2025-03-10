# note that opennms needs to be running for provisioning commands to work
# as they use the ReST interface.
log 'Start OpenNMS to perform ReST operations.' do
  notifies :start, 'service[opennms]', :immediately
end

# required foreign source
opennms_foreign_source 'another-source'

# errrythin
opennms_service_detector 'Router' do
  class_name 'org.opennms.netmgt.provision.detector.snmp.SnmpDetector'
  foreign_source_name 'another-source'
  parameters 'vbname' => '.1.3.6.1.2.1.4.1.0', 'vbvalue' => '1', 'port' => '161', 'retries' => '3', 'timeout' => '5000'
end

# minimal
opennms_service_detector 'ICMP' do
  class_name 'org.opennms.netmgt.provision.detector.icmp.IcmpDetector'
  foreign_source_name 'another-source'
end

# modify by adding a previously missing things
opennms_service_detector 'change ICMP timeout' do
  service_name 'ICMP'
  foreign_source_name 'another-source'
  parameters 'ipMatch' => '127.0.0.1', 'timeout' => '12000'
end

# something with spaces in it

opennms_service_detector 'ICMP but with spaces' do
  service_name 'I C M P'
  foreign_source_name 'another-source'
  parameters 'ipMatch' => '127.0.0.1', 'timeout' => '12000'
end
