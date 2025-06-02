control 'service_detector' do
  describe service_detector('Router', 'another-source', 1246) do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.simple.TcpDetector' }
    its('parameters') { should eq 'banner' => 'heaven', 'port' => '80', 'retries' => '5', 'timeout' => '6000' }
  end
end
