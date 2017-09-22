# frozen_string_literal: true
control 'expression_change_value' do
  describe expression('cheftest', 'icmp / 1000', 'if', 'high', 'and', [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]) do
    it { should exist }
    its('value') { should eq 30.0 }
  end
end
