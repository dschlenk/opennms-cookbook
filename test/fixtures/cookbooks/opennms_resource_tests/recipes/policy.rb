# frozen_string_literal: true
# note that opennms needs to be running for provisioning commands to work
# as they use the ReST interface.
log 'Start OpenNMS to perform ReST operations.' do
  notifies :start, 'service[opennms]', :immediately
end

# required foreign source
opennms_foreign_source 'policy-source'

# standard practice
opennms_policy 'Production Category' do
  class_name 'org.opennms.netmgt.provision.persist.policies.NodeCategorySettingPolicy'
  foreign_source_name 'policy-source'
  parameters 'category' => 'Test', 'matchBehavior' => 'ALL_PARAMETERS'
end
