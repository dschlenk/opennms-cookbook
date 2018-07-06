# frozen_string_literal: true
control 'poller' do
  describe poll_outage('ignore localhost on mondays') do
    it { should exist }
    its('times') { should eq 'mondays' => { 'day' => 'monday', 'begins' => '00:00:00', 'ends' => '23:59:59' } }
    its('type') { should eq 'weekly' }
    its('interfaces') { should eq ['127.0.0.1'] }
  end
  describe poll_outage('ignore localhost on mondays') do
    it { should exist }
    its('times') { should eq 'mondays' => { 'day' => 'monday', 'begins' => '00:00:00', 'ends' => '23:59:59' } }
    its('type') { should eq 'weekly' }
    its('nodes') { should eq [1] }
  end
end
