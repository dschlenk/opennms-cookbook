# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_jdbc_collection_service "JDBCFoo" do
  collection "foo"
  package_name "foo"
  interval 400000
  user_defined true
  status "off"
  timeout 5000
  retry_count 10
  port 15432
  thresholding_enabled true
  driver "org.postgresql.Driver"
  #driver_file "jdbc.jar"  # must be present in cookbook files for non-PostgreSQL databases
  user "wibble"
  password "wobble"
  url "jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble"
  notifies :restart, "service[opennms]", :delayed
end

# minimal
opennms_jdbc_collection_service "JDBC" do
  collection 'default'
  driver "org.postgresql.Driver"
  user "wibble"
  password "wobble"
  url "jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble"
  notifies :restart, "service[opennms]", :delayed
end
