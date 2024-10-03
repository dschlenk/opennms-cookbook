include_recipe 'opennms_resource_tests::service_detector'
opennms_service_detector 'nochange Router' do
  service_name 'Router'
  foreign_source_name 'another-source'
  port 80
  retry_count 5
  timeout 6000
  parameters 'banner' => 'heaven'
end
