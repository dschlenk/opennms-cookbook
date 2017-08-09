control 'collection_graph_file' do
  files = ['wimax-gw-graph.properties',
    'xups-graph.properties',
    'hwg-graph.properties',
  ]
  notfiles = ['mailmarshal-graph.properties']
  files.each do |f|
    describe collection_graph_file f do
      its('exists') { should eq true }
    end
  end
  notfiles.each do |f|
    describe collection_graph_file f do
      its('exists') { should eq false }
    end
  end
end
