include_recipe 'opennms_resource_tests::xml_collection'
include_recipe 'opennms_resource_tests::xml_source'

# test deletion
opennms_xml_source 'delete a thing' do
  url 'http://{ipaddr}/to-delete'
  collection_name 'foo'
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end

# delete source that has all options that form identity
opennms_xml_source 'delete big example' do
  url 'http://{ipaddr}/get-example'
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => 6000, 'retries' => 2
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  import_groups ['mygroups.xml']
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end

opennms_xml_source 'delete nothing' do
  url 'http://{ipaddr}/pants-example'
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => 6000, 'retries' => 2
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  import_groups ['mygroups.xml']
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end

opennms_xml_source 'delete nothing minimal' do
  url 'http://{ipaddr}/shirt-example'
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => 6000, 'retries' => 2
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  request_content "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>"
  import_groups ['mygroups.xml']
  action :delete
  notifies :restart, 'service[opennms]', :delayed
end
