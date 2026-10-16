name 'opennms_collection_package_delete'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk21', 'opennms', 'opennms_resource_tests::collection_package_delete'
cookbook 'opennms', path: '../'
cookbook 'openjdk21', path: '../test/fixtures/cookbooks/openjdk21'
cookbook 'opennms_resource_tests', path: '../test/fixtures/cookbooks/opennms_resource_tests'
