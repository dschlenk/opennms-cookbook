name 'opennms-upgrade'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk17', 'opennms-no-upgrade', 'opennms'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
cookbook 'opennms-no-upgrade', path: '../test/fixtures/cookbooks/no_upgrade'
