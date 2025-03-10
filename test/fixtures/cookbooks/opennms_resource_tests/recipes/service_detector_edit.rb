include_recipe 'opennms_resource_tests::service_detector'
opennms_service_detector 'change Router class' do
  service_name 'Router'
  class_name 'org.opennms.netmgt.provision.detector.simple.TcpDetector'
  foreign_source_name 'another-source'
end
opennms_service_detector 'change Router port' do
  service_name 'Router'
  foreign_source_name 'another-source'
  parameters 'port' => '80'
end
opennms_service_detector 'change Router retry_count' do
  service_name 'Router'
  foreign_source_name 'another-source'
  parameters 'retries' => '5'
end
opennms_service_detector 'change Router timeout' do
  service_name 'Router'
  foreign_source_name 'another-source'
  parameters 'timeout' => '6000'
end
opennms_service_detector 'change Router params' do
  service_name 'Router'
  foreign_source_name 'another-source'
  parameters 'banner' => 'heaven'
end

opennms_service_detector 'change spacey ICMP' do
  service_name 'I C M P'
  foreign_source_name 'another-source'
  parameters 'timeout' => 7000
end
