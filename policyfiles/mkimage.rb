name 'mkimage'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk21', 'opennms', 'mkimage'
cookbook 'opennms', path: '../'
cookbook 'openjdk21', path: '../test/fixtures/cookbooks/openjdk21'
cookbook 'mkimage', path: '../test/fixtures/cookbooks/mkimage'
