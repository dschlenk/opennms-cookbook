# all options
opennms_disco_range "anRange" do
  range_begin '10.0.0.1' 
  range_end  '10.0.0.254'
  range_type 'include'  # can be 'include' or 'exclude'
  retry_count 37
  timeout 6000
  # tell discovery daemon to use new config
  notifies :run, 'opennms_send_event[activate_discovery-configuration.xml]'
end

# minimal
opennms_disco_range "anOtherRange" do
  range_begin '192.168.0.1'
  range_end '192.168.254.254'
  range_type 'exclude'
end

log "Start OpenNMS to perform ReST operations." do
  notifies :start, 'service[opennms]', :immediately
end

opennms_foreign_source 'disco-source'

# with foreign source
opennms_disco_range "anForeignSourceRange" do
  range_begin '10.1.0.1'
  range_end '10.1.0.254'
  foreign_source 'disco-source'
end
