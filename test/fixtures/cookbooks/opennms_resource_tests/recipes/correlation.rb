if respond_to?(:opennms_drools_correlation_rule)

  opennms_drools_correlation_rule 'basic-rule' do
    engine_source 'drools-engine.xml.erb'
    engine_source_variables(
      rule_name: 'basic-rule',
      engine_name: 'BasicEngine',
      drl_files: ['sample.drl']
    )
    drl_source ['sample.drl']
  end

  opennms_drools_correlation_rule 'template-rule' do
    engine_source_type 'template'
    engine_source 'drools-engine.xml.erb'
    engine_source_variables(
      engine_name: 'TemplateEngine',
      rule_name: 'TemplateRule',
      drl_files: ['template-rule.drl']
    )
    drl_source ['template-rule.drl']
  end

  opennms_drools_correlation_rule 'cookbook-drl-rule' do
    engine_source 'drools-engine.xml.erb'
    engine_source_variables(
      engine_name: 'CookbookEngine',
      rule_name: 'CookbookRule',
      drl_files: ['sample.drl']
    )
    drl_source ['sample.drl']
    drl_source_type 'cookbook_file'
    drl_source_properties(
      mode: '0755',
      owner: 'opennms',
      group: 'opennms'
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
      engine_name: 'Overridden',
      rule_name: 'OverriddenRule'
    )
    engine_source_properties(
      mode: '0600'
    )
    drl_source ['override-rule.drl']
  end

  opennms_drools_correlation_rule 'create-if-missing-rule' do
    engine_source 'drools-engine.xml.erb'
    engine_source_variables(
      engine_name: 'MissingEngine',
      rule_name: 'MissingRule',
      drl_files: ['create-if-missing.drl']
    )
    drl_source ['create-if-missing.drl']
    action :create_if_missing
  end

  opennms_drools_correlation_rule 'user-defined-rule' do
    engine_source_type 'template'
    engine_source 'drools-engine.xml.erb'
    engine_source_variables(
      engine_name: 'UserEngine',
      rule_name: 'UserDefinedRule',
      drl_files: ['user-defined-rule.drl', 'template-rule.drl', 'sample.drl']
    )
    drl_source ['user-defined-rule.drl', 'template-rule.drl', 'sample.drl']
    drl_source_type 'template'
    drl_source_variables(
      rule_name: 'UserDefinedRule',
      import_class: 'com.example.model.Alert',
      condition: '$alert : Alert(severity == "CRITICAL")',
      action: 'System.out.println("Critical alert: " + $alert.getMessage());'
    )
  end

else
  Chef::Log.warn("The resource 'opennms_drools_correlation_rule' is not available. Please ensure the 'opennms' cookbook is included.")
end
