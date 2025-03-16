include_recipe 'opennms_resource_tests::expression'

opennms_expression 'change relaxed on ping latency thing' do
  expression 'icmp / 1000'
  group 'cheftest'
  type 'high'
  ds_type 'if'
  relaxed true
  filter_operator 'and'
  triggered_uei 'uei.opennms.org/thresholdTest/testThresholdExceeded'
  rearmed_uei 'uei.opennms.org/thresholdTest/testThresholdRearmed'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
