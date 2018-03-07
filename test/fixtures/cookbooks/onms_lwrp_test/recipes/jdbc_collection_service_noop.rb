# frozen_string_literal: true
include_recipe 'onms_lwrp_test::jdbc_collection_service_edit'
opennms_jdbc_collection_service 'JDBCFoo nothing' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
end

opennms_jdbc_collection_service 'JDBCFoo still nothing' do
  service_name 'JDBCFoo'
  collection 'foo'
  package_name 'foo'
  interval 500_000
  user_defined false
  status 'on'
  timeout 6000
  retry_count 3
  port 88
  thresholding_enabled false
  driver 'org.place.Driver'
  user 'jimmy'
  password 'johnny'
  url 'jdbc:place:server:database'
end
