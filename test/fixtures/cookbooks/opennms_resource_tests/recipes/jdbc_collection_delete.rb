include_recipe 'opennms_resource_tests::jdbc_collection'
opennms_jdbc_collection 'foo' do
  action :delete
end

opennms_jdbc_collection 'delete MySQL-Global-Stats' do
  collection 'MySQL-Global-Stats'
  action :delete
end
