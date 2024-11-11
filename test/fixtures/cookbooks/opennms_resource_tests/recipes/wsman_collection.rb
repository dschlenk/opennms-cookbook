# A collectd package's service references the collection to store data in with
# a collection parameter, so this resource must be defined earlier in the run
# list than any package service that references it.
#
# all options
opennms_wsman_collection 'foo' do
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  include_system_definitions true
end

# minimal
opennms_wsman_collection 'bar'

# edit existing
opennms_wsman_collection 'default' do
  rrd_step 301
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  include_system_definitions false
  include_system_definition ['Microsoft Windows (All Versions)', 'Dell iDRAC (All Version)', 'Dell iDRAC 8']
  action :update
end

opennms_wsman_collection 'the same as the one before but nothing happens even though it is a different action' do
  collection 'default'
  rrd_step 301
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  include_system_definitions false
  include_system_definition ['Microsoft Windows (All Versions)', 'Dell iDRAC (All Version)', 'Dell iDRAC 8']
  action :create
end
