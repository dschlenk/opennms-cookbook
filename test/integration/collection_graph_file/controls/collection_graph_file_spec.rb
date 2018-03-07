# frozen_string_literal: true
control 'collection_graph_file' do
  files = ['wimax-gw-graph.properties',
           'xups-graph.properties',
           'hwg-graph.properties',
  ]
  notfiles = ['mailmarshal-graph.properties']
  files.each do |f|
    describe collection_graph_file f do
      it { should exist }
    end
  end
  notfiles.each do |f|
    describe collection_graph_file f do
      it { should_not exist }
    end
  end
end
