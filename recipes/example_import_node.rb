# mixin our library
class Chef::Recipe
  include Provision
end
# note that opennms needs to be running for provisioning commands to work 
# as they use the ReST interface. 
log "Start OpenNMS to perform ReST operations." do
    notifies :start, 'service[opennms]', :immediately
end
# minimal
opennms_import_node "nodeA" do
  foreign_source_name "dry-source"
  foreign_id "nodeA_ID"
end

# make us a new foreign_id using the Provision library
nodeB_foreign_id = foreign_id_gen
# common options
opennms_import_node "nodeB" do
  foreign_source_name "dry-source"
  foreign_id nodeB_foreign_id
  building "HQ"
  categories ["Servers", "Test"]
  assets 'vendorPhone' => '411', 'serialNumber' => 'SN12838931'
end

nodeC_foreign_id = foreign_id_gen
# all options
opennms_import_node "nodeC" do
  foreign_source_name "dry-source"
  foreign_id nodeC_foreign_id
  parent_foreign_source 'dry-source'
  parent_foreign_id nodeB_foreign_id
  parent_node_label "nodeB"
  city "Tulsa"
  building "Barn"
  categories ["Servers", "Test"]
  assets 'vendorPhone' => '511', 'serialNumber' => 'SN12838932'
  sync_import true
end
