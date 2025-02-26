# A collectd package's service references the collection to store data in with
# a collection parameter, so this resource must be defined earlier in the run
# list than any package service that references it.
#
# all options
opennms_jdbc_collection 'foo' do
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
end

# minimal
opennms_jdbc_collection 'bar'

opennms_jdbc_collection 'create_if_missing' do
  rrd_step 600
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:732', 'RRA:MIN:0.5:576:732']
  action :create_if_missing
end

opennms_jdbc_collection 'noop_create_if_missing' do
  collection 'create_if_missing'
  rrd_step 700
  rras ['RRA:AVERAGE:0.5:2:4033', 'RRA:AVERAGE:0.5:24:2977', 'RRA:AVERAGE:0.5:576:733', 'RRA:MAX:0.5:576:733', 'RRA:MIN:0.5:576:733']
  action :create_if_missing
end
