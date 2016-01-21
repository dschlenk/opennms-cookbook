# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end
# all options
opennms_import "saucy-source" do
  foreign_source_name 'saucy-source'
  sync_import true
  sync_wait_periods 30
  sync_wait_secs 10
end

#minimal
opennms_import "dry-source" do
  foreign_source_name "dry-source" 
end
