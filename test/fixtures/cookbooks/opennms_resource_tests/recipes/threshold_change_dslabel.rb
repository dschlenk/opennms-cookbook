include_recipe 'opennms_resource_tests::threshold'

# change ds-label
opennms_threshold 'change ds-label on espresso' do
  ds_name 'espresso'
  group 'coffee'
  type 'low'
  ds_type 'if'
  ds_label 'ifName'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end