# frozen_string_literal: true
control 'service_detector_edit' do
  describe service_detector('Router', 'another-source') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.detector.simple.TcpDetector' }
    its('port') { should eq 80 }
    its('retry_count') { should eq 5 }
    its('time_out') { should eq 6000 }
    its('parameters') { should eq 'banner' => 'heaven' }
  end
end
