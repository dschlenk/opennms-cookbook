name 'opennms_event_remove_tticket'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk17', 'opennms', 'opennms_resource_tests::event_remove_tticket'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
cookbook 'opennms_resource_tests', path: '../test/fixtures/cookbooks/opennms_resource_tests'