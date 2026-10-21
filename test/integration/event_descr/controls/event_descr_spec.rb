# frozen_string_literal: true

control 'event_descr' do
  describe fetch_live_eventconf('chef.events') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'uei.opennms.org/cheftest/thresholdExceeded2' }
    its('stdout') { should include '<p>A thresholds defined by a chef recipe has been exceeded.</p>' }
  end
end
