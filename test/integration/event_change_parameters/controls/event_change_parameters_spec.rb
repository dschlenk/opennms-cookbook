# frozen_string_literal: true

control 'event_change_parameters' do
  describe fetch_live_eventconf('chef.events') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'uei.opennms.org/cheftest/thresholdExceeded2' }
    its('stdout') { should include 'param1' }
    its('stdout') { should include 'value1' }
    its('stdout') { should include 'param2' }
    its('stdout') { should include 'value2' }
    its('stdout') { should include '"expand":false' }
  end
end
