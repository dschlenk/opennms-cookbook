control 'service_detector' do
  describe foreign_source('another-source', 1238) do
    it { should exist }
  end

  describe service_detector('Router', 'another-source', 1238) do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.snmp.SnmpDetector' }
    its('parameters') { should eq 'vbname' => '.1.3.6.1.2.1.4.1.0', 'vbvalue' => '1', 'port' => '161', 'retries' => '3', 'timeout' => '5000' }
  end

  describe service_detector('ICMP', 'another-source', 1238) do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.icmp.IcmpDetector' }
  end

  describe service_detector('ICMP', 'another-source', 1238) do
    it { should exist }
    its('parameters') { should eq 'ipMatch' => '127.0.0.1', 'timeout' => '12000' }
  end

  describe service_detector('I C M P', 'another-source', 1238) do
    it { should exist }
    its('parameters') { should eq 'ipMatch' => '127.0.0.1', 'timeout' => '12000' }
  end
end
