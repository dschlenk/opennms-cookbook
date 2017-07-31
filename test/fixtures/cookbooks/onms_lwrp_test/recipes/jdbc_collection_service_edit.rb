# frozen_string_literal: true
include_recipe 'onms_lwrp_test::jdbc_collection_service'
opennms_jdbc_collection_service 'JDBCFoo interval' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  interval 500_000
end

opennms_jdbc_collection_service 'JDBCFoo user_defined' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  user_defined false
end

opennms_jdbc_collection_service 'JDBCFoo status' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  status 'on'
end

opennms_jdbc_collection_service 'JDBCFoo timeout' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  timeout 6000
end

opennms_jdbc_collection_service 'JDBCFoo retry_count' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  retry_count 3
end

opennms_jdbc_collection_service 'JDBCFoo port' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  port 88
end

opennms_jdbc_collection_service 'JDBCFoo thresholding_enabled' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  thresholding_enabled false
end

opennms_jdbc_collection_service 'JDBCFoo driver' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  driver 'org.place.Driver'
end

opennms_jdbc_collection_service 'JDBCFoo user' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  user 'jimmy'
end

opennms_jdbc_collection_service 'JDBCFoo password' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  password 'johnny'
end

opennms_jdbc_collection_service 'JDBCFoo url' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  url 'jdbc:place:server:database'
end
