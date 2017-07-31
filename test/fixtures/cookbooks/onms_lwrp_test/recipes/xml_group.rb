# frozen_string_literal: true
# required by group
opennms_xml_source 'http://{ipaddr}/group-example' do
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => 6000, 'retries' => 2
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  request_content "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>"
  import_groups ['mygroups.xml']
  notifies :restart, 'service[opennms]', :delayed
end
# all options
opennms_xml_group 'fxa-sc' do
  source_url 'http://{ipaddr}/group-example'
  collection_name 'foo'
  resource_type 'dnsDns'
  key_xpath '@measObjLdn'
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue"
  timestamp_xpath '/measCollecFile/fileFooter/measCollec/@endTime'
  timestamp_format "yyyy-MM-dd'T'HH:mm:ssZ"
  objects 'nasdaq' => { 'type' => 'gauge', 'xpath' => "/blah/elmeentalaewflk[@attribute='avalue']" }
  notifies :restart, 'service[opennms]', :delayed
end
# minimal - adds to a source created with that LWRP
opennms_xml_group 'minimal' do
  source_url 'http://{ipaddr}/get-minimal'
  collection_name 'foo'
  resource_xpath '/minimal/group'
  notifies :restart, 'service[opennms]', :delayed
end
