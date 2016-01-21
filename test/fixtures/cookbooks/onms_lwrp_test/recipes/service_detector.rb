# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end

# required foreign source
opennms_foreign_source "another-source"

# errrythin
opennms_service_detector "Router" do
  class_name "org.opennms.netmgt.provision.detector.snmp.SnmpDetector"
  foreign_source_name "another-source"
  port 161
  retry_count 3
  timeout 5000
  params 'vbname' => '.1.3.6.1.2.1.4.1.0', 'vbvalue' => '1'
end

# minimal
opennms_service_detector "ICMP" do
  class_name "org.opennms.netmgt.provision.detector.icmp.IcmpDetector"
  foreign_source_name "another-source"
end
