# frozen_string_literal: true
control 'threshold_change_dslabel' do
  espresso = {
    'ds_name' => 'espresso',
    'group' => 'coffee',
    'type' => 'low',
    'ds_type' => 'if',
    'filter_operator' => 'and',
    'resource_filters' => [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }],
    'triggered_uei' => 'uei.opennms.org/thresholdTrigger',
    'rearmed_uei' => 'uei.opennms.org/thresholdRearm',
  }
  describe threshold(espresso) do
    it { should exist }
    its('ds_label') { should eq 'ifName' }
  end
end
