# frozen_string_literal: true
include_recipe 'onms_lwrp_test::service_detector.rb'
opennms_service_detector 'change Router class' do
  service_name 'Router'
  class_name 'org.opennms.netmgt.provision.detector.simple.TcpDetector'
  foreign_source_name 'another-source'
end
opennms_service_detector 'change Router port' do
  service_name 'Router'
  foreign_source_name 'another-source'
  port 80
end
opennms_service_detector 'change Router retry_count' do
  service_name 'Router'
  foreign_source_name 'another-source'
  retry_count 5
end
opennms_service_detector 'change Router timeout' do
  service_name 'Router'
  foreign_source_name 'another-source'
  timeout 6000
end
opennms_service_detector 'change Router params' do
  service_name 'Router'
  foreign_source_name 'another-source'
  params 'banner' => 'heaven'
end
