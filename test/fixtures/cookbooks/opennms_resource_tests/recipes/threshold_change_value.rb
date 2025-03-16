include_recipe 'opennms_resource_tests::threshold'

# change value
opennms_threshold 'change espresso value' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  value 10.0
  filter_operator 'and'
  triggered_uei 'uei.opennms.org/thresholdTrigger'
  rearmed_uei 'uei.opennms.org/thresholdRearm'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
