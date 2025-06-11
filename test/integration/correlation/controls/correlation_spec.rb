control 'correlation' do
  describe file('/opt/opennms/etc/drools-engine.d/remote-engine-rule/drools-engine.xml') do
    it { should exist }
  end

  describe file('/opt/opennms/etc/drools-engine.d/override-template-rule/drools-engine.xml') do
    it { should exist }
    its('content') { should match /OverriddenRule/ }
  end

  describe file('/opt/opennms/etc/drools-engine.d/template-rule/drools-engine.xml') do
    it { should exist }
    its('content') { should match /TemplateEngine/ }
    its('content') { should match /TemplateRule/ }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-drl-rule/drools-engine.xml') do
    it { should exist }
  end

  describe file('/opt/opennms/etc/drools-engine.d/cookbook-drl-rule/sample.drl') do
    its('mode') { should cmp '0755' }
    its('owner') { should eq 'opennms' }
    its('group') { should eq 'opennms' }
  end

  describe file('/opt/opennms/etc/drools-engine.d/create-if-missing-rule/drools-engine.xml') do
    it { should exist }
  end

  describe file('/opt/opennms/etc/drools-engine.d/nonexistent-rule') do
    it { should_not exist }
  end
end
