# most useful options
# A collectd package's service references the collection to store data in with 
# a collection parameter, so this resource must be defined earlier in the run 
# list than any package service that depends references it. 
opennms_snmp_collection "baz" do
  max_vars_per_pdu 75
  snmp_stor_flag "all"
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032','RRA:AVERAGE:0.5:24:2976','RRA:AVERAGE:0.5:576:732','RRA:MAX:0.5:576:732','RRA:MIN:0.5:576:732']
end

# minimal
opennms_snmp_collection "qux"
