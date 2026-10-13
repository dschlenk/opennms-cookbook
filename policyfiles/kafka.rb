name 'kafka'
default_source :supermarket
run_list 'openjdk17', 'kafka_default', 'opennms::postgres', 'opennms'
cookbook 'kafka_default', path: '../test/fixtures/cookbooks/kafka_default'
cookbook 'opennms', path: '../'
cookbook 'openjdk17', path: '../test/fixtures/cookbooks/openjdk17'
