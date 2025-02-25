control 'collection_graph_file' do
  files = ['wimax-gw-graph.properties',
           'xups-graph.properties',
           'hwg-graph.properties',
           'Synology-Storage-graph.properties',
  ]
  notfiles = ['mailmarshal-graph.properties', 'apc.graph.properties']
  files.each do |f|
    describe collection_graph_file f do
      it { should exist }
      if f == 'Synology-Storage-graph.properties'
        sscontents = <<-EOL
reports=synoDisk.Temperature, \\
synoSystem.Temperature


report.synoDisk.Temperature.name=Synology Disk Temperature
report.synoDisk.Temperature.columns=synoDiskTemp
report.synoDisk.Temperature.type=diskEntry
report.synoDisk.Temperature.description=Synology disk temperature The temperature of each disk uses Celsius degree. 
report.synoDisk.Temperature.command=--title="Synology Disk Temperature" \\
--vertical-label="Celsius" \\
 DEF:var={rrd1}:synoDiskTemp:AVERAGE \\
 LINE1:var#00ccff:"Temperature" \\
 GPRINT:var:AVERAGE:"Avg\\\\: %8.2lf %s" \\
 GPRINT:var:MIN:"Min\\\\: %8.2lf %s" \\
 GPRINT:var:MAX:"Max\\\\: %8.2lf %s\\\\n" \\

report.synoSystem.Temperature.name=Synology System Temperature
report.synoSystem.Temperature.columns=synoSysTemp
report.synoSystem.Temperature.type=nodeSnmp
report.synoSystem.Temperature.description=Synology system temperature. The temperature of Disk Station uses Celsius degree. 
report.synoSystem.Temperature.command=--title="Synology System Temperature" \\
--vertical-label="Celsius" \\
 DEF:var={rrd1}:synoSysTemp:AVERAGE \\
 LINE1:var#00ccff:"Temperature" \\
 GPRINT:var:AVERAGE:"Avg\\\\: %8.2lf %s" \\
 GPRINT:var:MIN:"Min\\\\: %8.2lf %s" \\
 GPRINT:var:MAX:"Max\\\\: %8.2lf %s\\\\n"
EOL
        its('content') { should cmp sscontents }
      end
    end
  end
  notfiles.each do |f|
    describe collection_graph_file f do
      it { should_not exist }
    end
  end
end
