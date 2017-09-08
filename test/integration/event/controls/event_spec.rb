# frozen_string_literal: true
control 'event' do
  describe event('uei.opennms.org/cheftest/thresholdExceeded', 'events/chef.events.xml') do
    it { should exist }
    its('event_label') { should eq 'Chef defined event: thresholdExceeded' }
    its('descr') { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its('logmsg') { should eq 'A threshold has been exceeded.' }
    its('logmsg_dest') { should eq 'logndisplay' }
    its('logmsg_notify') { should be true }
    its('severity') { should eq 'Minor' }
    its('alarm_data') { should eq({ 'reduction_key' => '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%', 'alarm_type' => 1, 'auto_clean' => false }) }
  end
end
