# frozen_string_literal: true
control 'poller_delete' do
  describe poller_service('SNMPBar2', 'bar') do
    it { should_not exist }
  end
end
