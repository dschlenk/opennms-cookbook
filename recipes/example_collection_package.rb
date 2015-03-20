# most useful options
opennms_collection_package "foo" do
  filter "(IPADDR != '0.0.0.0') & (categoryName == 'foo')"
  specifics ['10.0.0.1']
  include_ranges [{'begin' => '10.0.1.1', 'end' => '10.0.1.254'}]
  exclude_ranges [{'begin' => '10.0.2.1', 'end' => '10.0.2.254'}]
  include_urls ['file:/opt/opennms/etc/foo']
  store_by_if_alias true
  if_alias_domain 'foo.com'
  # collectd requires a restart for changes to take effect
  notifies :restart, "service[opennms]", :delayed
end

# minimal
opennms_collection_package "bar" do
  filter "IPADDR != '0.0.0.0'"
  notifies :restart, "service[opennms]", :delayed
end
