include_recipe 'opennms_resource_tests::xml_source'
# required by group
opennms_xml_source 'http://{ipaddr}/group-example' do
  collection_name 'foo'
  request_method 'GET'
  request_params 'timeout' => 6000, 'retries' => 2
  request_headers 'User-Agent' => 'HotJava/1.1.2 FCS'
  request_content "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>"
  import_groups ['mygroups.xml']
end
# all options with key_xpath
opennms_xml_group 'fxa-sc' do
  source_url 'http://{ipaddr}/group-example'
  collection_name 'foo'
  resource_type 'dnsDns'
  key_xpath '@measObjLdn'
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue"
  timestamp_xpath '/measCollecFile/fileFooter/measCollec/@endTime'
  timestamp_format "yyyy-MM-dd'T'HH:mm:ssZ"
  objects 'nasdaq' => { 'type' => 'gauge', 'xpath' => "/blah/elmeentalaewflk[@attribute='avalue']" }
end
# all options with resource_keys
opennms_xml_group 'fxa-sc-rk' do
  source_url 'http://{ipaddr}/group-example'
  collection_name 'foo'
  resource_type 'dnsDns'
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue"
  timestamp_xpath '/measCollecFile/fileFooter/measCollec/@endTime'
  timestamp_format "yyyy-MM-dd'T'HH:mm:ssZ"
  resource_keys ['@measObjLdn', '@measObjInstId']
  objects 'nasdaq' => { 'type' => 'gauge', 'xpath' => "/blah/elmeentalaewflk[@attribute='avalue']" }
end
# minimal - adds to a source created with that LWRP
opennms_xml_group 'minimal' do
  source_url 'http://{ipaddr}/get-minimal'
  collection_name 'foo'
  resource_xpath '/minimal/group'
end

# populate a tributary file
opennms_xml_group 'file' do
  file 'file-group.xml'
  resource_xpath '/files/file'
  key_xpath '@path'
  objects(
    'size' => { 'type' => 'gauge', 'xpath' => '@size' }
  )
end

# add to the file using the alternate objects format
opennms_xml_group 'file2' do
  file 'file-group.xml'
  resource_xpath '/filez/file'
  key_xpath '@inode'
  objects [{ 'name' => 'atime', 'type' => 'string', 'xpath' => '@atime' }, { 'name' => 'mtime', 'type' => 'string', 'xpath' => '@mtime' }]
end

opennms_xml_group 'create-if-missing' do
  source_url 'http://{ipaddr}/group-example'
  collection_name 'foo'
  resource_type 'dnsDns'
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue"
  action :create_if_missing
end

opennms_xml_group 'noop-create-if-missing' do
  source_url 'http://{ipaddr}/group-example'
  collection_name 'foo'
  resource_type 'dnsDnss'
  resource_xpath "/measCollecFile/measData/measInfo[@measInfoId='dns|dnss']/measValue"
  action :create_if_missing
end
