# frozen_string_literal: true
control 'notification_edit' do
  describe notification('example2Broken') do
    it { should exist }
    its('status') { should eq 'off' }
    its('uei') { should eq 'changedTheUei' }
    its('destination_path') { should eq 'Email-Admin' }
    its('text_message') { should eq 'broken' }
  end
end
