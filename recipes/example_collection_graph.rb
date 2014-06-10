# let's implement the coffee mib - starting with adding a file to datacollection
opennms_snmp_collection_group "coffee" do
  file "coffee.xml"
end

# add a file that has a coffee temperature graph in it. 
opennms_collection_graph_file "coffee.properties"

# okay, let's add a graph to that file that shows beverage level min, max, avg
opennms_collection_graph "coffee.potLevel" do
  long_name "Coffee Pot Level"
  columns ["coffeePotCapacity","coffeePotLevel"]
  type "nodeSnmp"
  command '--title="Coffee Beverages" --vertical-label="Beverages" DEF:capacity={rrd1}:coffeePotCapacity:AVERAGE DEF:minLevel={rrd2}:coffeePotLevel:MIN DEF:maxLevel={rrd2}:coffeePotLevel:MAX DEF:avgLevel={rrd2}:coffeePotLevel:AVERAGE LINE1:rt#0000ff:"Total Beverages" GPRINT:capacity:AVERAGE:" Cap  \\\\: %8.2lf %s" GPRINT:minLevel:MIN:"Min  \\\\: %8.2lf %s" GPRINT:maxLevel:MAX:"Max  \\\\: %8.2lf %s" GPRINT:avgLevel:AVERAGE:"Avg  \\\\: %8.2lf %s\\\\n'
  file "coffee.properties"
end

# add a new graph def to a new file
opennms_collection_graph "coffee.potLevel2" do
  long_name "Coffee Pot Level2"
  columns ["coffeePotCapacity","coffeePotLevel"]
  type "nodeSnmp"
  command '--title="Coffee Beverages2" --vertical-label="Beverages" DEF:capacity={rrd1}:coffeePotCapacity:AVERAGE DEF:minLevel={rrd2}:coffeePotLevel:MIN DEF:maxLevel={rrd2}:coffeePotLevel:MAX DEF:avgLevel={rrd2}:coffeePotLevel:AVERAGE LINE1:rt#0000ff:"Total Beverages" GPRINT:capacity:AVERAGE:" Cap  \\\\: %8.2lf %s" GPRINT:minLevel:MIN:"Min  \\\\: %8.2lf %s" GPRINT:maxLevel:MAX:"Max  \\\\: %8.2lf %s" GPRINT:avgLevel:AVERAGE:"Avg  \\\\: %8.2lf %s\\\\n'
  file "coffee2.properties"
end
