# Note that package_name and collection must be defined somewhere
# else in your resource collection.
#
# most useful options
opennms_jdbc_collection_service "JDBCFoo" do
  service_name 'JDBCFoo'
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

opennms_jdbc_collection_service "JDBCFoo interval" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  interval 500000
end

opennms_jdbc_collection_service "JDBCFoo user_defined" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  user_defined false
end

opennms_jdbc_collection_service "JDBCFoo status" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  status 'on'
end

opennms_jdbc_collection_service "JDBCFoo timeout" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  timeout 6000
end

opennms_jdbc_collection_service "JDBCFoo retry_count" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  retry_count 3
end

opennms_jdbc_collection_service "JDBCFoo port" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  port 88
end

opennms_jdbc_collection_service "JDBCFoo thresholding_enabled" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  thresholding_enabled false
end

opennms_jdbc_collection_service "JDBCFoo driver" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  driver 'org.place.Driver'
end

opennms_jdbc_collection_service "JDBCFoo user" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  user 'jimmy'
end

opennms_jdbc_collection_service "JDBCFoo password" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  password 'johnny'
end

opennms_jdbc_collection_service "JDBCFoo url" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  url 'jdbc:place:server:database'
end

opennms_jdbc_collection_service "JDBCFoo nothing" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
end

opennms_jdbc_collection_service "JDBCFoo still nothing" do
  service_name 'JDBCFoo'
  collection "foo"
  package_name "foo"
  interval 500000
  user_defined false
  status "on"
  timeout 6000
  retry_count 3
  port 88
  thresholding_enabled false
  driver "org.place.Driver"
  user "jimmy"
  password "johnny"
  url "jdbc:place:server:database"
end
