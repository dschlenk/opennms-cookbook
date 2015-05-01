# all options
opennms_disco_specific "10.10.1.1" do
  retry_count 13
  timeout 4000
  # changes takes place without a restart if you do this
  notifies :run, 'opennms_send_event[activate_discovery-configuration.xml]'
end

# minimal, and probably more typical
opennms_disco_specific "10.10.1.2"

log "Start OpenNMS to perform ReST operations." do
  notifies :start, 'service[opennms]', :immediately
end
opennms_foreign_source 'disco-specific-source'

# with foreign source
opennms_disco_specific "10.3.0.1" do
  foreign_source 'disco-specific-source'
end
