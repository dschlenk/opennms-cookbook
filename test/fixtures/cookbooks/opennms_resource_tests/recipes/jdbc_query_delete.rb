include_recipe 'opennms_resource_tests::jdbc_query'
opennms_jdbc_query 'ifaceServicesQuery' do
  collection_name 'foo'
  # since none of these are part of identity, but are required, it doesn't matter what you set them to
  if_type 'ignore'
  recheck_interval 1
  query_string 'select'
  action :delete
end
