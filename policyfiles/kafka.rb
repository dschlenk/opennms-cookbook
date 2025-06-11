name 'kafka'
default_source :supermarket
run_list 'openjdk17', 'zk', 'kafka', 'opennms::postgres', 'opennms'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
cookbook 'zk', path: '../test/fixtures/cookbooks/zk'
