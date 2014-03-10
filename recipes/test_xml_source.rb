# all options
opennms_xml_source "http://{ipaddr}/get-example" do
  collection_name "foo"
  resource_type "fake_xml_type"
  request_method "GET"
  request_params 'timeout' => 6000, 'retries' => 2 
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS' 
  request_content "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>"
  import_groups ["mygroups.xml"]
  notifies :restart, "service[opennms]", :delayed
end

#minimal
opennms_xml_source "http://{ipaddr}/get-minimal" do
  collection_name "foo"
  notifies :restart, "service[opennms]", :delayed
end
