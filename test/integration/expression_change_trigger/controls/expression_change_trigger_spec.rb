# frozen_string_literal: true
control 'expression_change_trigger' do
  expr = {
    'expression' => 'icmp / 1000',
    'group' => 'cheftest',
    'type' => 'high',
    'ds_type' => 'if',
    'filter_operator' => 'and',
    'resource_filters' => [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }],
  }
  describe expression(expr) do
    it { should exist }
    its('trigger') { should eq 5 }
  end
end
