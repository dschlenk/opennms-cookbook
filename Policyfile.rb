name 'opennms-templates'
default_source :supermarket
metadata
run_list 'opennms::postgres', 'openjdk17', 'opennms', 'opennms_resource_tests::user'
cookbook 'openjdk17', path: 'test/fixtures/cookbooks/openjdk17'
cookbook 'opennms_resource_tests', path: 'test/fixtures/cookbooks/opennms_resource_tests'
cookbook 'kafka'
