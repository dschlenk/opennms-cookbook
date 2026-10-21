# frozen_string_literal: true
control 'event_edit_forward' do
  # Directly query the live Horizon 35 database registry via the REST API
  describe command('curl -s -u admin:admin -H "Accept: application/json" http://localhost:8980/opennms/rest/eventconf') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include 'uei.opennms.org/cheftest/thresholdExceeded2' }
    its('stdout') { should include 'snmpudp' }
    its('stdout') { should include 'off' }
  end
end
