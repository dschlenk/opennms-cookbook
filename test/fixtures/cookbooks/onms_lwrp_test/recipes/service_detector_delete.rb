# frozen_string_literal: true
include_recipe 'onms_lwrp_test::service_detector'

# delete
opennms_service_detector 'delete ICMP' do
  service_name 'ICMP'
  class_name 'org.opennms.netmgt.provision.detector.icmp.IcmpDetector'
  foreign_source_name 'another-source'
  action :delete
end

opennms_service_detector 'delete spacy ICMP' do
  service_name 'I C M P'
  class_name 'org.opennms.netmgt.provision.detector.icmp.IcmpDetector'
  foreign_source_name 'another-source'
  action :delete
end
