# all options
opennms_xml_group "fxa-sc" do
  source_url "http://{ipaddr}/get-example"
  collection_name "foo"
  resource_type "dnsDns"
  key_xpath "@measObjLdn"
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue"
  timestamp_xpath "/measCollecFile/fileFooter/measCollec/@endTime"
  timestamp_format "yyyy-MM-dd'T'HH:mm:ssZ"
  objects 'nasdaq' => {'type' => 'gauge', 'xpath' => "/blah/elmeentalaewflk[@attribute='avalue']"}
  notifies :restart, "service[opennms]", :delayed
end
# minimal
opennms_xml_group "minimal" do
  source_url "http://{ipaddr}/get-minimal"
  collection_name "foo"
  resource_xpath "/minimal/group"
  notifies :restart, "service[opennms]", :delayed
end
