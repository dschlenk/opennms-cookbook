# frozen_string_literal: true

control 'event_remove_add_varbindsdecode' do
  title 'OpenNMS Event Remove and Add Varbindsdecode Validation'

  describe event('uei.opennms.org/cheftest/thresholdExceeded2', 'events/chef.events.xml') do
    it { should exist }
    its(%w(varbindsdecode)) { should eq([{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]) }
  end
end
