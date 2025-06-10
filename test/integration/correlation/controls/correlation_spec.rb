control 'correlation' do
  describe correlation_rule('remote-engine-rule') do
    it { should exist }
  end

  describe correlation_rule('override-template-rule') do
    it { should exist }
    its('content') { should match /OverriddenRule/ }
  end

  describe correlation_rule('template-rule') do
    it { should exist }
    its('content') { should match /TemplateEngine/ }
    its('content') { should match /TemplateRule/ }
  end

  describe correlation_rule('cookbook-drl-rule') do
    it { should exist }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-drl-rule/sample.drl') do
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe correlation_rule('create-if-missing-rule') do
    it { should exist }
  end

  describe correlation_rule('nonexistent-rule') do
    it { should_not exist }
  end
end
