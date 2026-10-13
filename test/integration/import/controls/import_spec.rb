# frozen_string_literal: true
control 'import' do
  describe import('saucy-source', 'saucy-source') do
    it { should exist }
  end
end
