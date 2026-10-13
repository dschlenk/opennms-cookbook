# frozen_string_literal: true

# required foreign source
opennms_foreign_source 'policy-source' do
  notifies :start, 'service[opennms]', :before
end

# standard practice
opennms_policy 'Production Category' do
  class_name 'org.opennms.netmgt.provision.persist.policies.NodeCategorySettingPolicy'
  foreign_source_name 'policy-source'
  parameters 'category' => 'Test', 'matchBehavior' => 'ALL_PARAMETERS'
end
