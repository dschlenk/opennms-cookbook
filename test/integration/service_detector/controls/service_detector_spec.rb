control 'service_detector' do
  describe foreign_source('another-source') do
    it { should exist }
  end

  describe service_detector('Router', 'another-source') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.snmp.SnmpDetector' }
    its('port') { should eq 161 }
    its('retry_count') { should eq 3 }
    its('time_out') { should eq 5000 }
    its('parameters') { should eq 'vbname' => '.1.3.6.1.2.1.4.1.0', 'vbvalue' => '1' }
  end

  describe service_detector('ICMP', 'another-source') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.icmp.IcmpDetector' }
  end

  describe service_detector('ICMP', 'another-source') do
    it { should exist }
    its('time_out') { should eq 12_000 }
    its('parameters') { should eq 'ipMatch' => '127.0.0.1' }
  end

  describe service_detector('I C M P', 'another-source') do
    it { should exist }
    its('time_out') { should eq 12_000 }
    its('parameters') { should eq 'ipMatch' => '127.0.0.1' }
  end
end
