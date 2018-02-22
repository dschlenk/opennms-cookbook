# frozen_string_literal: true
control 'threshold_change_rearmeduei' do
  espresso = {
    'ds_name' => 'espresso',
    'group' => 'coffee',
    'type' => 'low',
    'ds_type' => 'if',
    'filter_operator' => 'and',
    'resource_filters' => [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }],
  }
  describe threshold(espresso) do
    it { should exist }
    its('rearmed_uei') { should eq 'uei.opennms.org/thresholdTest/testThresholdRearmed' }
  end
end
