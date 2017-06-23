# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_xml_collection_service 'XMLFoo Service' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  interval 400_000
  user_defined true
  status 'off'
  timeout 5000
  retry_count 10
  port 8181
  thresholding_enabled true
  notifies :restart, 'service[opennms]', :delayed
end

# minimal
opennms_xml_collection_service 'XML Service' do
  collection 'default'
  notifies :restart, 'service[opennms]', :delayed
end

# test updates
opennms_xml_collection_service 'change XMLFoo interval' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  interval 500_000
end

opennms_xml_collection_service 'change XMLFoo user_defined' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  user_defined false
end

opennms_xml_collection_service 'XMLFoo status' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  status 'on'
end

opennms_xml_collection_service 'XMLFoo timeout' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  timeout 6000
end

opennms_xml_collection_service 'XMLFoo retry_count' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  retry_count 11
end

opennms_xml_collection_service 'XMLFoo port' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  port 12
end

opennms_xml_collection_service 'XMLFoo thresholding_enabled' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  thresholding_enabled false
end

opennms_xml_collection_service 'XMLFoo nothing' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
end

opennms_xml_collection_service 'XMLFoo still nothing' do
  service_name 'XMLFoo'
  collection 'foo'
  package_name 'foo'
  thresholding_enabled false
  port 12
  retry_count 11
  timeout 6000
  status 'on'
  interval 500_000
end

# test create_if_missing
opennms_xml_collection_service 'create_if_missing XML Service' do
  status 'off'
  action :create_if_missing
end

# test delete
opennms_xml_collection_service 'delete XML Service' do
  collection 'default'
  action :delete
end
