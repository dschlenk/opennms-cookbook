# frozen_string_literal: true

control 'event_label' do
  title 'OpenNMS Event Label Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('eventLabel') { should eq 'Chef definedd event: thresholdExceeded' }
  end
end
