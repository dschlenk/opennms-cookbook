# frozen_string_literal: true

control 'event_edit_mouseovertext' do
  describe fetch_live_eventconf('chef.events') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'uei.opennms.org/cheftest/thresholdExceeded2' }
    its('stdout') { should include 'mouseOverTexted' }
  end
end
