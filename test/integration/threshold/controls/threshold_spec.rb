# frozen_string_literal: true
control 'threshold' do
  ping = {
    'ds_name' => 'icmp',
    'group' => 'cheftest',
    'type' => 'high',
    'ds_type' => 'if',
  }
  describe threshold(ping) do
    it { should exist }
    its('description') { should eq 'ping latency too high' }
    its('value') { should eq 20_000.0 }
    its('rearm') { should eq 18_000.0 }
    its('trigger') { should eq 2 }
  end

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
    its('description') { should eq 'alarm when percentage of espresso in bloodstream too low' }
    its('value') { should eq 50.0 }
    its('rearm') { should eq 60.0 }
    its('trigger') { should eq 3 }
    its('ds_label') { should eq 'bloodEspressoContent' }
  end
end
