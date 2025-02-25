include_recipe 'opennms_resource_tests::collection_package'
include_recipe 'opennms_resource_tests::jdbc_collection'
# most useful options
opennms_jdbc_collection_service 'JDBCFoo' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  interval 400_000
  user_defined true
  status 'off'
  timeout 5000
  retry_count 10
  port 15_432
  thresholding_enabled true
  driver 'org.postgresql.Driver'
  driver_file 'jdbc.jar' # must be present in cookbook files for non-PostgreSQL databases
  user 'wibble'
  password 'wobble'
  url 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble'
end

# minimal
opennms_jdbc_collection_service 'JDBC' do
  collection 'default'
  driver 'org.postgresql.Driver'
  user 'wibble'
  password 'wobble'
  url 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble'
end

opennms_jdbc_collection_service 'JDBC_create_if_missing' do
  service_name 'JDBC_create_if_missing'
  collection 'create_if_missing'
  package_name 'createifmissing'
  interval 400_000
  user_defined true
  status 'off'
  timeout 5000
  retry_count 10
  port 15_432
  thresholding_enabled true
  driver 'org.postgresql.Driver'
  driver_file 'jdbc.jar'
  user 'wibble'
  password 'wobble'
  url 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobble'
  action :create_if_missing
end

opennms_jdbc_collection_service 'JDBC_noop_create_if_missing' do
  service_name 'JDBC_create_if_missing'
  package_name 'createifmissing'
  collection 'default'
  interval 400_001
  user_defined false
  status 'on'
  timeout 5001
  retry_count 11
  port 15_433
  thresholding_enabled false
  driver 'org.postgresql.Driver'
  driver_file 'jdbc.jarr'
  user 'wibblee'
  password 'wobblee'
  url 'jdbc:postgresql://OPENNMS_JDBC_HOSTNAME:15432/wibble_wobblee'
  action :create_if_missing
end
