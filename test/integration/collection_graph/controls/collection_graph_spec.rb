control 'collection_graph' do
  describe snmp_collection_group('coffee', 'coffee.xml') do
    it { should exist }
  end

  describe collection_graph_file('coffee.properties') do
    it { should exist }
    its('md5sum') { should eq '524f3a2eda81c751d93e0ef8efa38be3' }
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
