include_recipe 'opennms_resource_tests::jdbc_collection'
opennms_jdbc_collection 'foo' do
  rrd_step 601
  rras ['RRA:AVERAGE:0.5:2:4032', 'RRA:AVERAGE:0.5:24:2976', 'RRA:AVERAGE:0.5:576:732', 'RRA:MAX:0.5:576:731']
end

opennms_jdbc_collection 'bar' do
  rrd_step 302
end
