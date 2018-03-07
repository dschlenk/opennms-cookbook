# frozen_string_literal: true
include_recipe 'onms_lwrp_test::expression'

opennms_expression 'change description on ping latency thing' do
  expression 'icmp / 1000'
  group 'cheftest'
  type 'high'
  ds_type 'if'
  description 'ping latency too damn high expression'
  filter_operator 'and'
  resource_filters [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]
end
