# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_snmp_collection_service "SNMP" do
  collection "baz"
  package_name "foo"
  interval 400000
  user_defined true
  status "off"
  timeout 5000
  retry_count 10
  port 1161
  thresholding_enabled true
  notifies :restart, "service[opennms]", :delayed
end

# minimal
opennms_snmp_collection_service "SNMP-bar" do
  package_name "bar"
  collection 'default'
  notifies :restart, "service[opennms]", :delayed
end
