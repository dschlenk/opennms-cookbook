name 'opennms-templates'
default_source :supermarket
metadata
run_list 'opennms::postgres', 'openjdk17', 'opennms'
cookbook 'openjdk17', path: 'test/fixtures/cookbooks/openjdk17'
