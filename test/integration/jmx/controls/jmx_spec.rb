# frozen_string_literal: true
control 'jmx' do
  describe collection_package 'jmx1' do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
  end

  describe jmx_collection('jmxcollection') do
    it { should exist }
    its('rrd_step') { should eq 300 }
    its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  end

  describe jmx_collection_service('jmx', 'jmxcollection', 'jmx1') do
    it { should exist }
    its('ds_name') { should eq 'jmx-ds-name' }
    its('friendly_name') { should eq 'jmx-friendly-name' }
    its('interval') { should eq 300000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('collection_timeout') { should eq 3000 }
    its('retry_count') { should eq 1 }
    its('thresholding_enabled') { should eq false }
    its('port') { should eq 1099 }
    its('protocol') { should eq 'rmi' }
    its('url_path') { should eq '/jmxrmi' }
    its('rrd_base_name') { should eq 'java' }
  end

  describe jmx_mbean('org.apache.activemq.Queue', 'jmxcollection') do
    it { should exist }
    its('objectname') { should eq 'org.apache.activemq:BrokerName=msgbroker-a.pe.spanlink.com,Type=Queue,Destination=splk.sw' }
    its('attribs') { should eq 'ConsumerCount' => { 'alias' => '5ConsumerCnt', 'type' => 'gauge' }, 'InFlightCount' => { 'alias' => '5InFlightCnt', 'type' => 'gauge' } }
  end
end
