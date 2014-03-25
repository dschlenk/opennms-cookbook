# drops off a new file
opennms_collection_graph_file "wimax-gw-graph.properties"
# our version has changes that won't get propogated, because create_if_missing.
opennms_collection_graph_file "xups-graph.properties" do
  action :create_if_missing
end
# updates with LINE4s in the second graph instead of LINE2s. 
opennms_collection_graph_file "hwg-graph.properties"
# deletes
opennms_collection_graph_file "mailmarshal-graph.properties" do
 action :delete
end
