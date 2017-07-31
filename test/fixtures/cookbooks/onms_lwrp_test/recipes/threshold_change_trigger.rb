# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshold'

# change trigger
opennms_threshold 'change trigger on espresso' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  trigger 2
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
