# frozen_string_literal: true

control 'event_edit_varbindsdecode' do
  title 'OpenNMS Event Varbindsdecode Configuration'

  describe opennms_event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its('varbindsdecode') { should eq([{ 'parmid' => 'theParmIds', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
  end
end
