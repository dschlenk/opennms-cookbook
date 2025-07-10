# simple rule that uses a template for drools-engine.xml that allows for every config option available by the schema
node.override['opennms']['services']['correlator'] = true
opennms_correlation 'basic-rule' do
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    rule_sets: [{ 'name' => 'basic-rule', 'rule_files' => ['sample.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService'], 'app_context' => 'sampleContext.xml', 'globals' => [{ 'name' => 'LOG', 'ref' => 'slf4jLogger' }] }]
  )
  drl_source ['sampleContext.xml', 'sample.drl']
end

# same template used for drools-engine.xml as above but simpler drl file requires less complex variables
opennms_correlation 'template-rule' do
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    rule_sets: [{ 'name' => 'TemplateRule', 'rule_files' => ['template-rule.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService'] }]
  )
  drl_source ['template-rule.drl']
end

# test use of drl_source_properties and engine_source_properties
opennms_correlation 'cookbook-drl-rule' do
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    rule_sets: [{ 'name' => 'CookbookRule', 'rule_files' => ['sample.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService'], 'app_context' => 'sampleContext.xml', 'globals' => [{ 'name' => 'LOG', 'ref' => 'slf4jLogger' }] }]
  )
  engine_source_properties(
    mode: '00755'
  )
  drl_source ['sampleContext.xml', 'sample.drl']
  drl_source_properties(
    mode: '00755'
  )
end

# download DRL files from github
opennms_correlation 'remote-engine-rule' do
  # using cookbook_file since remote version runs in a test harness with incompatible paths to the rule-file
  engine_source_type 'cookbook_file'
  engine_source 'sample-race-tests-drools-engine.xml'
  drl_source ['https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/AvgCacheBwUsageRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/AvgOriginBwUsageRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/ConnectionRateRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/CorrelationRaceConditionRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/InterfaceDownRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/MemUtilizationRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/NetUtilizationRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/NodeDownRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/PagingActivityRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/ResourcePoolUtilRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/TransactionRateRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/WriteMemRules.drl',
             ]
  drl_source_type 'remote_file'
  drl_source_properties(
    show_progress: true
  )
end

opennms_correlation 'remote-everything' do
  engine_source_type 'remote_file'
  engine_source 'https://gist.githubusercontent.com/dschlenk/2b2a32bf53c22b61083778cabd5fd0ad/raw/ee47d1dd02013c304f76f88dafcdd008e22d6922/gistfile1.txt'
  engine_source_properties(
    show_progress: true
  )
  drl_source_type 'remote_file'
  drl_source ['https://gist.githubusercontent.com/dschlenk/2224f03a2df6a737d929351c9e1bbedd/raw/89a332f7b793401683f5346c90bff4f575f77003/PersistStateStreaming.drl']
end

opennms_correlation 'cookbook-everything' do
  engine_source_type 'cookbook_file'
  engine_source 'cookbook-file-drools-engine.xml'
  drl_source ['sample.drl', 'sampleContext.xml']
end
