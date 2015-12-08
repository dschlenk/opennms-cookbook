# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_xml_collection_service "XMLFoo Service" do
  service_name 'XMLFoo'
  collection "foo"
  package_name "foo"
  interval 400000
  user_defined true
  status "off"
  timeout 5000
  retry_count 10
  port 8181
  thresholding_enabled true
  notifies :restart, "service[opennms]", :delayed
end

# minimal
opennms_xml_collection_service "XML Service" do
  collection 'default'
  notifies :restart, "service[opennms]", :delayed
end
