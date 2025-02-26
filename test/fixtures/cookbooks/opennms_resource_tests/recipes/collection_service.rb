include_recipe 'opennms_resource_tests::collection_package'
# most useful options
opennms_collection_service 'JSON' do
  collection 'baz'
  package_name 'foo'
  class_name 'org.opennms.protocols.xml.collector.XmlCollector'
  interval 400_000
  user_defined true
  status 'off'
  timeout 5000
  retry_count 10
  port 1161
  parameters 'handler-class' => 'org.opennms.protocols.json.collector.DefaultJsonCollectionHandler'
  thresholding_enabled true
  notifies :restart, 'service[opennms]', :delayed
end

# minimal that'll get you JSON
opennms_collection_service 'JSON-bar' do
  package_name 'bar'
  collection 'default'
  class_name 'org.opennms.protocols.xml.collector.XmlCollector'
  parameters 'handler-class' => 'org.opennms.protocols.json.collector.DefaultJsonCollectionHandler'
  notifies :restart, 'service[opennms]', :delayed
end
