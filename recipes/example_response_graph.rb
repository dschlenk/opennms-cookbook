# mixin our library
class Chef::Recipe
  include Provision
end
# opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end
# create a poller service in the default package
opennms_poller_service "ONMS" do
  class_name "org.opennms.netmgt.poller.monitors.HttpMonitor"
  port 8980
  params 'url' => '/opennms/login.jsp', 'rrd-repository' => '/opt/opennms/share/rrd/response', 'rrd-base-name' => 'onms', 'ds-name' => 'onms'
  notifies :restart, 'service[opennms]'
end
opennms_foreign_source "dry-source"
opennms_import "dry-source"
# make us a new foreign_id using the Provision library
rgfsid = foreign_id_gen
# make a node to add an interface to
opennms_import_node "responseGraphTestNode" do
  foreign_source_name "dry-source"
  foreign_id rgfsid
  building "HQ"
  categories ["Servers", "Test"]
end

# add interface to node
opennms_import_node_interface "127.0.0.1" do
  foreign_source_name "dry-source"
  foreign_id rgfsid
end

# add service to node
opennms_import_node_interface_service "ONMS" do
  foreign_source_name "dry-source"
  foreign_id rgfsid
  ip_addr "127.0.0.1"
  sync_import true
end

# add a graph for that service
opennms_response_graph "onms"

# with all options it would look like
opennms_response_graph "onms.avg" do
  long_name "OpenNMS Response Time"
  columns ['onms']
  type ['responseTime']
  command "--title=\"OpenNMS Web Interface Response Time\"  \\\n --vertical-label=\"Milliseconds\" \\\n  DEF:avgrt={rrd1}:onms:AVERAGE \\\n LINE2:avgrt#0000ff:\"Response Time\" \\\n GPRINT:avgrt:AVERAGE:\" Avg \\\\: %8.2lf %s\\\\n"
end
