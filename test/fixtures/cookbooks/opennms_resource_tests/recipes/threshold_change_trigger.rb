include_recipe 'opennms_resource_tests::threshold'

# change trigger
opennms_threshold 'change trigger on espresso' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  trigger 2
  filter_operator 'and'
  triggered_uei 'uei.opennms.org/thresholdTrigger'
  rearmed_uei 'uei.opennms.org/thresholdRearm'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
