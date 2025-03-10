include_recipe 'opennms_resource_tests::service_detector'
opennms_service_detector 'nochange Router' do
  service_name 'Router'
  foreign_source_name 'another-source'
  parameters 'banner' => 'heaven', 'port' => '80', 'retries' => '5', 'timeout' => '6000'
end
