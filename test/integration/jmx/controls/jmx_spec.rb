control 'jmx' do
  describe collection_package 'jmx1' do
    it { should exist }
    its('filter') { should eq "IPADDR != '0.0.0.0'" }
  end

  # describe jmx_collection('jmxcollection') do
  #   it { should exist }
  #   its('rrd_step') { should eq 300 }
  #   its('rras') { should eq ['RRA:AVERAGE:0.5:1:2016', 'RRA:AVERAGE:0.5:12:1488', 'RRA:AVERAGE:0.5:288:366', 'RRA:MAX:0.5:288:366', 'RRA:MIN:0.5:288:366'] }
  # end

  describe collection_service('jmx', 'jmx1') do
    it { should exist }
    its('collection') { should eq 'jmxcollection' }
    its('parameters') { should cmp 'ds-name' => 'jmx-ds-name', 'friendly-name' => 'jmx-friendly-name', 'rrd-base-name' => 'java' }
    its('interval') { should eq 300000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq false }
  end

  # describe jmx_mbean('org.apache.activemq.Queue', 'jmxcollection', 'org.apache.activemq:BrokerName=broker.example.com,Type=Queue,Destination=anQueue') do
  #   it { should exist }
  #   its('attribs') { should eq 'ConsumerCount' => { 'alias' => 'anQConsumerCnt', 'type' => 'gauge' }, 'InFlightCount' => { 'alias' => 'anQFlightCnt', 'type' => 'gauge' } }
  # end

  # describe jmx_mbean('org.apache.activemq.Queue', 'jmxcollection', 'org.apache.activemq:BrokerName=broker.example.com,Type=Queue,Destination=anotherQueue') do
  #   it { should exist }
  #   its('attribs') { should eq 'ConsumerCount' => { 'alias' => 'anoQConsumerCnt', 'type' => 'gauge' }, 'InFlightCount' => { 'alias' => 'anoQInflightCnt', 'type' => 'gauge' } }
  # end

  describe collection_service('jmx_url', 'jmx1') do
    its('collection') { should eq 'jmxcollection' }
    its('parameters') { should cmp 'ds-name' => 'jmx-ds-name', 'friendly-name' => 'jmx-friendly-name', 'url' => 'service:jmx:rmi:${ipaddr}:18980', 'factory' => 'SASL', 'username' => 'bart', 'password' => 'simpson', 'rrd-base-name' => 'java' }
    its('interval') { should eq 300000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq false }
  end

  describe collection_service('jmx_url_path', 'jmx1') do
    its('collection') { should eq 'jmxcollection' }
    its('parameters') { should cmp 'ds-name' => 'jmx-ds-name', 'friendly-name' => 'jmx-friendly-name', 'factory' => 'SASL', 'username' => 'bart', 'password' => 'simpson', 'rrd-base-name' => 'java', 'urlPath' => '/jmxrmi', 'protocol' => 'rmi', 'rmiServerPort' => '45444', 'remoteJMX' => 'true' }
    its('interval') { should eq 300000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq false }
  end

  describe collection_service('jmx_url_ignore_path', 'jmx1') do
    its('collection') { should eq 'jmxcollection' }
    its('parameters') { should cmp 'ds-name' => 'jmx-ds-name', 'friendly-name' => 'jmx-friendly-name', 'factory' => 'SASL', 'username' => 'bart', 'password' => 'simpson', 'rrd-base-name' => 'java', 'url' => 'service:jmx:rmi:${ipaddr}:18980' }
    its('interval') { should eq 300000 }
    its('user_defined') { should eq false }
    its('status') { should eq 'on' }
    its('thresholding_enabled') { should eq false }
  end
end
