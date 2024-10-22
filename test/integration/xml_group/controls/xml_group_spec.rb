control 'xml_group' do
  describe xml_source('http://{ipaddr}/group-example', 'foo') do
    it { should exist }
    its('request_method') { should eq 'GET' }
    its('request_params') { should eq 'timeout' => '6000', 'retries' => '2' }
    its('request_headers') { should eq 'User-Agent' => 'HotJava/1.1.2 FCS' }
    its('request_content') { should eq "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>" }
    its('import_groups') { should eq ['mygroups.xml'] }
  end

  describe xml_group('fxa-sc', 'http://{ipaddr}/group-example', 'foo') do
    it { should exist }
    its('resource_type') { should eq 'dnsDns' }
    its('key_xpath') { should eq '@measObjLdn' }
    its('resource_xpath') { should eq "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue" }
    its('timestamp_xpath') { should eq '/measCollecFile/fileFooter/measCollec/@endTime' }
    its('timestamp_format') { should eq "yyyy-MM-dd'T'HH:mm:ssZ" }
    its('objects') { should eq 'nasdaq' => { 'type' => 'gauge', 'xpath' => "/blah/elmeentalaewflk[@attribute='avalue']" } }
  end

  describe xml_group('fxa-sc-rk', 'http://{ipaddr}/group-example', 'foo') do
    it { should exist }
    its('resource_type') { should eq 'dnsDns' }
    its('resource_keys') { should eq ['@measObjLdn', '@measObjInstId'] }
    its('key_xpath') { should eq nil }
    its('resource_xpath') { should eq "/measCollecFile/measData/measInfo[@measInfoId='dns|dns']/measValue" }
    its('timestamp_xpath') { should eq '/measCollecFile/fileFooter/measCollec/@endTime' }
    its('timestamp_format') { should eq "yyyy-MM-dd'T'HH:mm:ssZ" }
    its('objects') { should eq 'nasdaq' => { 'type' => 'gauge', 'xpath' => "/blah/elmeentalaewflk[@attribute='avalue']" } }
  end

  describe xml_group('minimal', 'http://{ipaddr}/get-minimal', 'foo') do
    it { should exist }
    its('resource_type') { should eq 'node' }
    its('resource_xpath') { should eq '/minimal/group' }
  end

  describe xml_group_file('file-group.xml', 'file') do
    it { should exist }
    its('resource_xpath') { should eq '/files/file' }
    its('key_xpath') { should eq '@path' }
    its('objects') { should eq 'size' => { 'type' => 'gauge', 'xpath' => '@size' } }
  end

  describe xml_group_file('file-group.xml', 'file2') do
    it { should exist }
    its('resource_xpath') { should eq '/filez/file' }
    its('key_xpath') { should eq '@inode' }
    its('objects') { should eq 'atime' => { 'type' => 'string', 'xpath' => '@atime' }, 'mtime' => { 'type' => 'string', 'xpath' => '@mtime' } }
  end
end
