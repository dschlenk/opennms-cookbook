control 'expression' do
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
    its('relaxed') { should be false }
    its('description') { should eq 'ping latency too high expression' }
    its('value') { should eq 20.0 }
    its('rearm') { should eq 18.0 }
    its('trigger') { should eq 3 }
  end
end
