name 'opennms-templates'
default_source :supermarket
metadata
run_list 'opennms::postgres', 'openjdk21', 'opennms', 'opennms_resource_tests::user'
cookbook 'openjdk21', path: 'test/fixtures/cookbooks/openjdk21'
cookbook 'opennms_resource_tests', path: 'test/fixtures/cookbooks/opennms_resource_tests'
cookbook 'kafka'
