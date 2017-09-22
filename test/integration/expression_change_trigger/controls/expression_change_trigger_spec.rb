# frozen_string_literal: true
control 'expression_change_trigger' do
  describe expression('cheftest', 'icmp / 1000', 'if', 'high', 'and', [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]) do
    it { should exist }
    its('trigger') { should eq 5 }
  end
end
