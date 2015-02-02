# most useful options
# Note that package_name 'foo' must be defined somewhere else in your resource collection.
opennms_wmi_collection_service "WMIFoo" do
  collection "foo"
  package_name "foo"
  interval 400000
  user_defined true
  status "off"
  timeout 5000
  retry_count 10
  port 4445
  thresholding_enabled true
  notifies :restart, "service[opennms]", :delayed
end

# minimal
opennms_wmi_collection_service "WMIBar" do
  collection 'default'
  notifies :restart, "service[opennms]", :delayed
end
