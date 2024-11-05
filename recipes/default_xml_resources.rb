opennms_xml_collection 'xml-elasticsearch-cluster-stats' do
  rras ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366']
end

opennms_xml_source 'http://{ipaddr}:9200/_cluster/stats' do
  collection_name 'xml-elasticsearch-cluster-stats'
  import_groups ['elasticsearch-cluster-stats.xml']
  import_groups_source 'external'
end
