include_recipe 'opennms_resource_tests::threshold'

# change triggeredUEI
opennms_threshold 'change triggeredUEI on espresso' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  triggered_uei 'uei.opennms.org/thresholdTest/testThresholdExceeded'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
