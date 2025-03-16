# frozen_string_literal: true
control 'expression_change_value' do
  expr = {
    'expression' => 'icmp / 1000',
    'group' => 'cheftest',
    'type' => 'high',
    'ds_type' => 'if',
    'filter_operator' => 'and',
    'resource_filters' => [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }],
    'triggered_uei' => 'uei.opennms.org/thresholdTest/testThresholdExceeded',
    'rearmed_uei' => 'uei.opennms.org/thresholdTest/testThresholdRearmed',
  }
  describe expression(expr) do
    it { should exist }
    its('value') { should eq 30.0 }
  end
end
