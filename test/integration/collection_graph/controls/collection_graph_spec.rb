control 'collection_graph' do
  describe snmp_collection_group('coffee', 'coffee.xml') do
    it { should exist }
  end

  describe collection_graph_file('coffee.properties') do
    it { should exist }
    its('content') do
      should eq <<-EOL
reports=coffee.temperature, \\
coffee.potLevel

report.coffee.temperature.name=Coffee Temperature
report.coffee.temperature.columns=coffeePotTemperature
report.coffee.temperature.type=nodeSnmp
report.coffee.temperature.command=--title="Coffee Pot Temperature" \\
 --vertical-label="Celsius" \\
 DEF:avgTemp={rrd1}:coffeePotTemperature:AVERAGE \\
 DEF:minTemp={rrd1}:coffeePotTemperature:MIN \\
 DEF:maxTemp={rrd1}:coffeePotTemperature:MAX \\
 CDEF:minSCAA=92 \\
 CDEF:maxSCAA=96 \\
 LINE1:minSCAA#00ff00:"SCAA Std. Min Temperature" \\
 STACK:maxSCAA#00ff00:"SCAA Std. Max Temperature" \\
 LINE1:minTemp#ffff00:"Min Temperature" \\
 LINE1:maxTemp#ff0000:"Max Temperature" \\
 LINE1:avgTemp#0000ff:"Avg Temperature" \\
 GPRINT:avgTemp:AVERAGE:" Avg  \\\\: %8.2lf %s" \\
 GPRINT:minTemp:MIN:"Min  \\\\: %8.2lf %s" \\
 GPRINT:maxTemp:MAX:"Max  \\\\: %8.2lf %s\\\\n"

report.coffee.potLevel.name=Coffee Pot Level
report.coffee.potLevel.columns=coffeePotCapacity, coffeePotLevel
report.coffee.potLevel.type=nodeSnmp
report.coffee.potLevel.command=--title="Coffee Beverages" --vertical-label="Beverages" DEF:capacity={rrd1}:coffeePotCapacity:AVERAGE DEF:minLevel={rrd2}:coffeePotLevel:MIN DEF:maxLevel={rrd2}:coffeePotLevel:MAX DEF:avgLevel={rrd2}:coffeePotLevel:AVERAGE LINE1:rt#0000ff:"Total Beverages" GPRINT:capacity:AVERAGE:" Cap  \\\\: %8.2lf %s" GPRINT:minLevel:MIN:"Min  \\\\: %8.2lf %s" GPRINT:maxLevel:MAX:"Max  \\\\: %8.2lf %s" GPRINT:avgLevel:AVERAGE:"Avg  \\\\: %8.2lf %s\\\\n
EOL
    end
  end

  describe collection_graph('coffee.properties', 'coffee.potLevel') do
    it { should exist }
    its('long_name') { should eq 'Coffee Pot Level' }
    its('columns') { should eq %w(coffeePotCapacity coffeePotLevel) }
    its('type') { should eq 'nodeSnmp' }
    its('command') { should eq '--title="Coffee Beverages" --vertical-label="Beverages" DEF:capacity={rrd1}:coffeePotCapacity:AVERAGE DEF:minLevel={rrd2}:coffeePotLevel:MIN DEF:maxLevel={rrd2}:coffeePotLevel:MAX DEF:avgLevel={rrd2}:coffeePotLevel:AVERAGE LINE1:rt#0000ff:"Total Beverages" GPRINT:capacity:AVERAGE:" Cap  \\: %8.2lf %s" GPRINT:minLevel:MIN:"Min  \\: %8.2lf %s" GPRINT:maxLevel:MAX:"Max  \\: %8.2lf %s" GPRINT:avgLevel:AVERAGE:"Avg  \\: %8.2lf %s\\n' }
  end

  describe collection_graph('coffee2.properties', 'coffee.potLevel2') do
    it { should exist }
    its('long_name') { should eq 'Coffee Pot Level2' }
    its('columns') { should eq %w(coffeePotCapacity coffeePotLevel) }
    its('type') { should eq 'nodeSnmp' }
    its('command') { should eq '--title="Coffee Beverages2" --vertical-label="Beverages" DEF:capacity={rrd1}:coffeePotCapacity:AVERAGE DEF:minLevel={rrd2}:coffeePotLevel:MIN DEF:maxLevel={rrd2}:coffeePotLevel:MAX DEF:avgLevel={rrd2}:coffeePotLevel:AVERAGE LINE1:rt#0000ff:"Total Beverages" GPRINT:capacity:AVERAGE:" Cap  \\: %8.2lf %s" GPRINT:minLevel:MIN:"Min  \\: %8.2lf %s" GPRINT:maxLevel:MAX:"Max  \\: %8.2lf %s" GPRINT:avgLevel:AVERAGE:"Avg  \\: %8.2lf %s\\n' }
  end
end
