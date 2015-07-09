# mixin our library
class Chef::Recipe
  include Provision
end
# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end
# need a node to add an interface to
# make us a new foreign_id using the Provision library
ifaceNode_foreign_id = foreign_id_gen
opennms_import_node "ifaceNode" do
  foreign_source_name "dry-source"
  foreign_id ifaceNode_foreign_id
  building "HQ"
  categories ["Servers", "Test"]
  assets 'vendorPhone' => '411', 'serialNumber' => 'SN12838931'
  sync_import true
end

# all options
opennms_import_node_interface "10.0.0.1" do
  foreign_source_name "dry-source"
  foreign_id ifaceNode_foreign_id
  managed true
  snmp_primary 'P'
  sync_import true
end

# minimal
opennms_import_node_interface "72.72.72.73" do
  foreign_source_name "dry-source"
  foreign_id ifaceNode_foreign_id
end
