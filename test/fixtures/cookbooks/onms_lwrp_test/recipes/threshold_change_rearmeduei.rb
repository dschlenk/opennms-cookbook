# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshold'

# change rearmedUEI
opennms_threshold 'change rearmedUEI on espresso' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  rearmed_uei 'uei.opennms.org/thresholdTest/testThresholdRearmed'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
