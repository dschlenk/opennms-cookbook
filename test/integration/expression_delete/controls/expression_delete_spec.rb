# frozen_string_literal: true
control 'expression_delete' do
  describe expression('cheftest', 'icmp / 1000', 'if', 'high', 'and', [{ 'field' => 'ifHighSpeed', 'filter' => '^[1-9]+[0-9]*$' }]) do
    it { should_not exist }
  end
end
