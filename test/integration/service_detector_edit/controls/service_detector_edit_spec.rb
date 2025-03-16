control 'service_detector_edit' do
  describe service_detector('Router', 'another-source', 1245) do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.simple.TcpDetector' }
    its('parameters') { should eq 'banner' => 'heaven', 'port' => '80', 'retries' => '5', 'timeout' => '6000' }
  end

  describe service_detector('I C M P', 'another-source', 1245) do
    it { should exist }
    its('parameters') { should eq 'ipMatch' => '127.0.0.1', 'timeout' => '7000' }
  end
end
