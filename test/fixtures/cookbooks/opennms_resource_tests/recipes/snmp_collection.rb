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
