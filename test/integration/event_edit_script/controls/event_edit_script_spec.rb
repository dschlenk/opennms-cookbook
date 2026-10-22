# frozen_string_literal: true

control 'event_edit_script' do
  title 'OpenNMS Event Script Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(script)) { should eq([{ 'content' => 'anScript', 'language' => 'beanshell' }]) }
  end
end
