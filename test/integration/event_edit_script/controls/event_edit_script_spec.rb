# frozen_string_literal: true

control 'event_edit_script' do
  title 'OpenNMS Event Script Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2') do
    it { should exist }
    its('script') { should eq([{ 'name' => 'anScript', 'language' => 'beanshell' }]) }
  end
end
