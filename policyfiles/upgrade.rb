name 'opennms-upgrade'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk17', 'opennms-upgrade', 'opennms'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
cookbook 'opennms-upgrade', path: '../test/fixtures/cookbooks/upgrade'
