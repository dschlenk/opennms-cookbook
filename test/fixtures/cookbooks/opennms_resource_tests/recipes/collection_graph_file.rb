# drops off a new file
opennms_collection_graph_file 'wimax-gw-graph.properties'
# our version has changes that won't get propogated, because create_if_missing.
opennms_collection_graph_file 'xups-graph.properties' do
  action :create_if_missing
end
# updates with LINE4s in the second graph instead of LINE2s.
opennms_collection_graph_file 'hwg-graph.properties'
# deletes
opennms_collection_graph_file 'mailmarshal-graph.properties' do
  action :delete
end
# use remote source
opennms_collection_graph_file 'Synology-Storage-graph.properties' do
  source 'https://raw.githubusercontent.com/opennms-config-modules/synology/f51730fa77fcbe02c030f0550ac515c93699c245/graphs/Synology-Storage-graph.properties'
end

opennms_collection_graph_file 'apc.graph.properties' do
  source 'https://raw.githubusercontent.com/opennms-config-modules/apc/612294d12d5178f3f8bff64e9e2e5fdbf4c331f8/graphs/apc.graph.properties'
  action [:create, :delete]
end
