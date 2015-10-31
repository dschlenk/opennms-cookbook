# mixin our library
class Chef::Recipe
  include Provision
end
# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end
serviceNode_foreign_id = foreign_id_gen
opennms_import_node "stressNode" do
  foreign_source_name "dry-source"
  foreign_id serviceNode_foreign_id
  building "HQ"
  categories ["Servers", "Test"]
  assets 'vendorPhone' => '412', 'serialNumber' => 'SN12838933'
  sync_import true
end

opennms_import_node_interface "72.72.72.75" do
  foreign_source_name "dry-source"
  foreign_id serviceNode_foreign_id
  sync_import true
end

services = ['ICMP', 'SSH', 'SNMP', 'HTTP', 'WMI', 'LDAP', 'IMAP', 'POP3', 'DNS', 'NTP', 'SIP', 'SCCP', 'HTTPS']
services.each do |svc|
  opennms_import_node_interface_service svc do
    foreign_source_name "dry-source"
    foreign_id serviceNode_foreign_id
    ip_addr "72.72.72.75"
    sync_import true
  end
end
