# frozen_string_literal: true

control 'event_edit_varbindsdecode' do
  title 'OpenNMS Event Varbindsdecode Configuration'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(varbindsdecode)) { should eq([{ 'parmid' => 'theParmIds', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
  end
end
