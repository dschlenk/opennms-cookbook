# frozen_string_literal: true

control 'event_descr' do
  title 'OpenNMS Event Description Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(descr)) { should eq '<p>A thresholds defined by a chef recipe has been exceeded.</p>' }
  end
end
