# frozen_string_literal: true
control 'policy' do
  describe foreign_source('policy-source') do
    it { should exist }
  end

  describe policy('Production Category', 'policy-source') do
    it { should exist }
    its('class_name') { should eq 'org.opennms.netmgt.provision.persist.policies.NodeCategorySettingPolicy' }
    its('parameters') { should eq 'category' => 'Test', 'matchBehavior' => 'ALL_PARAMETERS' }
  end
end
