include_recipe 'opennms_resource_tests::jdbc_collection_service_edit'
opennms_jdbc_collection_service 'JDBCFoo nothing' do
  service_name 'JDBCFoo'
  package_name 'foo'
  action :delete
end
