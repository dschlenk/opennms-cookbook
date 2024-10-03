# all options
include_recipe 'opennms_resource_tests::xml_collection'
opennms_xml_source 'http://{ipaddr}/get-example' do
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => 6000, 'retries' => 2
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  request_content "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>"
  import_groups ['mygroups.xml']
  notifies :restart, 'service[opennms]', :delayed
end

# minimal
opennms_xml_source 'http://{ipaddr}/get-minimal' do
  collection_name 'foo'
  notifies :restart, 'service[opennms]', :delayed
end

# use url attribute
opennms_xml_source 'something to delete' do
  url 'http://{ipaddr}/to-delete'
  collection_name 'foo'
  notifies :restart, 'service[opennms]', :delayed
end

# externally sourced import groups
opennms_xml_source 'netapp-snapmirror' do
  collection_name 'foo'
  url 'http://192.168.64.2/snapmirror.xml'
  import_groups ['netapp-snapmirror-stats.xml']
  import_groups_source 'https://raw.githubusercontent.com/opennms-config-modules/netapp-snapmirror/74877429c168c9db1e0fe96db2ecc5960274031d/xml-datacollection'
  notifies :restart, 'service[opennms]', :delayed
end
