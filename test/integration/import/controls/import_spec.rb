# frozen_string_literal: true
control 'import' do
  describe import('saucy-source', 'saucy-source', 1240) do
    it { should exist }
  end
end
