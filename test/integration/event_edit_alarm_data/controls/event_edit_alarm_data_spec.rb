# frozen_string_literal: true

control 'event_edit_alarm_data' do
  describe fetch_live_eventconf('chef.events') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'uei.opennms.org/cheftest/thresholdExceeded2' }
    its('stdout') { should include '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%aids' }
    its('stdout') { should include '"alarm-type":2' }
  end
end
