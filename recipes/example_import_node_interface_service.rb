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
serviceNode_foreign_id = foreign_id_gen
opennms_import_node "serviceNode" do
  foreign_source_name "dry-source"
  foreign_id serviceNode_foreign_id
  building "HQ"
  categories ["Servers", "Test"]
  assets 'vendorphone' => '411', 'serialnumber' => 'SN12838932'
end

# minimal
opennms_import_node_interface "72.72.72.74" do
  foreign_source_name "dry-source"
  foreign_id serviceNode_foreign_id
end

# all options - only sync_import is optional
opennms_import_node_interface_service "ICMP" do
  foreign_source_name "dry-source"
  foreign_id serviceNode_foreign_id
  ip_addr "72.72.72.74"
  sync_import true
end
