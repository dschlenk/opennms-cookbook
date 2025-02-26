opennms_snmp_collection 'baz' do
  max_vars_per_pdu 75
  snmp_stor_flag 'all'
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
end

# minimal
opennms_snmp_collection 'qux'

# with complex include_collections
opennms_snmp_collection 'cisco' do
  include_collections [
    { data_collection_group: 'MIB2', exclude_filters: ['^Cisco AS.*$'] },
    { data_collection_group: 'Cisco', exclude_filters: [] },
    { data_collection_group: 'Cisco Nexus', system_def: 'Cisco Nexus 7010' },
  ]
end

opennms_snmp_collection 'create_if_missing' do
  max_vars_per_pdu 75
  snmp_stor_flag 'all'
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  action :create_if_missing
end

opennms_snmp_collection 'noop_create_if_missing' do
  collection 'create_if_missing'
  max_vars_per_pdu 75
  snmp_stor_flag 'all'
  rrd_step 700
  rras ['RRA:AVERAGE:0.5:2:4033', 'RRA:AVERAGE:0.5:24:2977', 'RRA:AVERAGE:0.5:576:733', 'RRA:MAX:0.5:576:733', 'RRA:MIN:0.5:576:733']
  action :create_if_missing
end
