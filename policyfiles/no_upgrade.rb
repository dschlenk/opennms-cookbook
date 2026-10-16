name 'opennms-upgrade'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk21', 'opennms-no-upgrade', 'opennms'
cookbook 'opennms', path: '../'
cookbook 'openjdk21', path: '../test/fixtures/cookbooks/openjdk21'
cookbook 'opennms-no-upgrade', path: '../test/fixtures/cookbooks/no_upgrade'
