opennms_drools_correlation_rule 'basic-rule' do
  engine_source 'drools-engine.xml.erb'
  drl_source ['sample.drl']
end

opennms_drools_correlation_rule 'template-rule' do
  engine_source_type 'template'
  engine_source 'drools-engine.xml.erb'
  engine_source_variables(
    engine_name: 'TemplateEngine',
    rule_name: 'TemplateRule'
  )
  drl_source ['template-rule.drl']
end

opennms_drools_correlation_rule 'cookbook-drl-rule' do
  engine_source 'drools-engine.xml.erb'
  drl_source ['cookbook-rule.drl']
  drl_source_type 'cookbook_file'
  drl_source_properties(
    mode: '0700',
    owner: 'root',
    group: 'nobody'
  )
end

opennms_drools_correlation_rule 'remote-engine-rule' do
  engine_source_type 'remote_file'
  engine_source 'https://raw.githubusercontent.com/UberPinguin/opennms-drools-sample-race-tests/refs/heads/master/src/test/opennms-home/etc/drools-engine.d/OpenNMS_Tests/drools-engine.xml'
  engine_source_properties(
    mode: '0644',
    show_progress: true
  )
  drl_source ['remote-rule.drl']
end

opennms_drools_correlation_rule 'override-template-rule' do
  engine_source_type 'template'
  engine_source 'custom-engine.xml.erb'
  engine_source_variables(
    engine_name: 'OverrideEngine',
    rule_name: 'OverrideRule'
  )
  engine_source_properties(
    variables: { engine_name: 'Overridden', rule_name: 'OverriddenRule' },
    mode: '0600'
  )
  drl_source ['override-rule.drl']
end

opennms_drools_correlation_rule 'create-if-missing-rule' do
  engine_source 'drools-engine.xml.erb'
  drl_source ['create-if-missing.drl']
  action :create_if_missing
end
