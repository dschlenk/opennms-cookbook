# frozen_string_literal: true

control 'event_noop' do
  title 'OpenNMS Event Noop Baseline Validation'

  events_data = opennms_event_api.fetch_live_eventconf_json('chef.events')
  events_list = events_data['events'] || []

  describe 'Event uei.opennms.org/cheftest/thresholdExceeded2' do
    subject { events_list.find { |e| e['uei'] == 'uei.opennms.org/cheftest/thresholdExceeded2' } }

    it { should_not be_nil }
    its(['eventLabel']) { should eq 'Chef defined event: thresholdExceeded' }
    its(['descr']) { should eq '<p>A threshold defined by a chef recipe has been exceeded.</p>' }
    its(%w[logmsg content]) { should eq 'A threshold has been exceeded.' }
    its(%w[logmsg dest]) { should eq 'logndisplay' }
    its(%w[logmsg notify]) { should be true }
    its(['severity']) { should eq 'Minor' }
    its(['operinstruct']) { should eq 'the operinstruct' }
    its(['autoaction']) { should eq([{ 'content' => 'someaction', 'state' => 'off' }]) }
    its(['varbindsdecode']) { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
    its(%w[tticket content]) { should eq 'tticketInfo' }
    its(%w[tticket state]) { should eq 'off' }
    its(['forward']) { should eq([{ 'content' => 'fwdInfo', 'state' => 'off', 'mechanism' => 'snmptcp' }]) }
    its(['script']) { should eq([{ 'content' => 'anScript', 'language' => 'groovy' }]) }
    its(['mouseovertext']) { should eq 'mouseOverText' }
    its(%w[alarmData reductionKey]) { should eq '%uei%:%dpname%:%nodeid%:%interface%:%parm[ds]%:%parm[threshold]%:%parm[trigger]%:%parm[rearm]%:%parm[label]%' }
    its(%w[alarmData alarmType]) { should eq 1 }
    its(%w[alarmData autoClean]) { should be false }
  end
end
