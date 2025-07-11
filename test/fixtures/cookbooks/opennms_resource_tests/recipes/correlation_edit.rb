include_recipe 'opennms_resource_tests::correlation'

opennms_correlation 'modify drools-engine.xml of basic-rule' do
  rule_name 'basic-rule'
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    rule_sets: [{ 'name' => 'basic-rule', 'rule_files' => ['sample.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService', 'uei.opennms.org/nodes/nodeRegainedService'], 'app_context' => 'sampleContext.xml', 'globals' => [{ 'name' => 'LOG', 'ref' => 'slf4jLogger' }] }]
  )
  drl_source ['sampleContext.xml', 'sample.drl']
end

opennms_correlation 'add another drl to an existing ruleset' do
  rule_name 'template-rule'
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    rule_sets: [{ 'name' => 'TemplateRule', 'rule_files' => ['template-rule.drl', 'template-rule-too.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService'] }]
  )
  drl_source ['template-rule.drl', 'template-rule-too.drl']
end

opennms_correlation 'add another rule-set to an existing rule-set' do
  rule_name 'cookbook-drl-rule'
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    rule_sets: [{ 'name' => 'CookbookRule', 'rule_files' => ['sample.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService'], 'app_context' => 'sampleContext.xml', 'globals' => [{ 'name' => 'LOG', 'ref' => 'slf4jLogger' }] },
                { 'name' => 'CookbookRuleToo', 'rule_files' => ['sample-too.drl'], 'events' => ['uei.opennms.org/nodes/nodeLostService'] }]
  )
  engine_source_properties(
    mode: '00755'
  )
  drl_source ['sample-too.drl']
  drl_source_properties(
    mode: '00755'
  )
end

opennms_correlation 'change properties of some of the drl files' do
  rule_name 'remote-engine-rule'
  engine_source_type 'cookbook_file'
  engine_source 'sample-race-tests-drools-engine.xml'
  drl_source ['https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/AvgCacheBwUsageRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/TransactionRateRules.drl',
              'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/WriteMemRules.drl',
             ]
  drl_source_type 'remote_file'
  drl_source_properties(
    mode: '00777'
  )
end

# ensure :create_if_missing does nothing when the correlation exists
opennms_correlation 'noop remote-everything' do
  rule_name 'remote-everything'
  engine_source_type 'cookbook_file'
  engine_source 'cookbook-file-drools-engine.xml'
  drl_source ['sample.drl', 'sampleContext.xml']
  action :create_if_missing
end

opennms_correlation 'delete cookbook-everything' do
  rule_name 'cookbook-everything'
  action :delete
end

opennms_correlation 'hard restart' do
  rule_name 'hard-restart'
  engine_source_type 'cookbook_file'
  engine_source 'cookbook-file-drools-engine.xml'
  drl_source ['sample.drl', 'sampleContext.xml']
  notify_type 'hard'
end
