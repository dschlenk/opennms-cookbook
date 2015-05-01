# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end
# all options
opennms_foreign_source "saucy-source" do
  scan_interval "7d"
end

#minimal
opennms_foreign_source "dry-source" 
