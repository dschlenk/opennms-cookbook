# frozen_string_literal: true
control 'notification_delete' do
  describe notification('example2Broken') do
    it { should_not exist }
  end
end
