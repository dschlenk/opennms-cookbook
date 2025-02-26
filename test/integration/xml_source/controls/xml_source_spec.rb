# frozen_string_literal: true
control 'xml_source' do
  describe xml_source('http://{ipaddr}/get-example', 'foo') do
    it { should exist }
    its('request_method') { should eq 'GET' }
    its('request_params') { should eq 'timeout' => '6000', 'retries' => '2' }
    its('request_headers') { should eq 'User-Agent' => 'HotJava/1.1.2 FCS' }
    its('request_content') { should eq "<person>\n<firstName>Alejandro</firstName>\n<lastName>Galue</lastName>\n</person>" }
    its('import_groups') { should eq ['mygroups.xml'] }
  end

  describe xml_source('http://{ipaddr}/get-minimal', 'foo') do
    it { should exist }
  end

  describe xml_source('http://{ipaddr}/to-delete', 'foo') do
    it { should exist }
  end

  describe xml_source('http://192.168.64.2/snapmirror.xml', 'foo') do
    it { should exist }
  end

  describe xml_source('http://192.168.64.2/snapmirror.xml', 'create_if_missing') do
    it { should exist }
  end
end
