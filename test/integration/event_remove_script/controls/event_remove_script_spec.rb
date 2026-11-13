# frozen_string_literal: true

control 'event_remove_script' do
  title 'OpenNMS Event Remove Script Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_remove_script', 'events/chef.events.xml') do
    it { should exist }
    its('script') { should be_empty }
  end
end
