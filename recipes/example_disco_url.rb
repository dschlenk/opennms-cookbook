# all options
opennms_disco_url "file:/opt/opennms/etc/include" do
  file_name "include"
  retry_count 13
  timeout 4000
  notifies :run, 'opennms_send_event[activate_discovery-configuration.xml]'
end

# minimal
opennms_disco_url "http://example.com/include"

log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end

opennms_foreign_source 'disco-url-source'

# with foreign source
opennms_disco_url "http://other.net/things" do
  foreign_source 'disco-url-source'
end
