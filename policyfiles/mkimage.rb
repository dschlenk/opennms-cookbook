name 'mkimage'
default_source :supermarket
run_list 'opennms::postgres', 'openjdk17', 'opennms', 'mkimage'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
cookbook 'mkimage', path: '../test/fixtures/cookbooks/mkimage'
