name 'opennms_user_mod'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk21', 'opennms', 'opennms_resource_tests::user_mod'
cookbook 'opennms', path: '../'
cookbook 'openjdk21', path: '../test/fixtures/cookbooks/openjdk21'
cookbook 'opennms_resource_tests', path: '../test/fixtures/cookbooks/opennms_resource_tests'
