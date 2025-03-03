include_recipe 'opennms_resource_tests::threshold'

# change description
opennms_threshold 'change description on espression' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  description 'alarm when BEC too low'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
