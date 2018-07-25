# frozen_string_literal: true
include_recipe 'onms_lwrp_test::threshold'

# delete espresso
opennms_threshold 'delete espresso' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
  action :delete
end
