# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshold'

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
