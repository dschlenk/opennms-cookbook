name 'opennms_service_detector_edit'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk17', 'opennms', 'opennms_resource_tests::service_detector_edit'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
cookbook 'opennms_resource_tests', path: '../test/fixtures/cookbooks/opennms_resource_tests'
