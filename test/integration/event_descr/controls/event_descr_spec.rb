# frozen_string_literal: true

control 'event_descr' do
  title 'OpenNMS Event Description Validation'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2-event_descr', 'events/chef.events.xml') do
    it { should exist }
    its('descr') { should eq '<p>A thresholds defined by a chef recipe has been exceeded.</p>' }
  end
end
