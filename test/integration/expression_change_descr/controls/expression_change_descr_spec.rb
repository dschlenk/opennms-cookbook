# frozen_string_literal: true
control 'expression_change_descr' do
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
    its('description') { should eq 'ping latency too damn high expression' }
  end
end
