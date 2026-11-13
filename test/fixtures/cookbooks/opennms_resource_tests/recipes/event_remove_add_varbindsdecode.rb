# frozen_string_literal: true

include_recipe 'opennms_resource_tests::event_remove_varbindsdecode'

opennms_event 'add varbindsdecode back' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_add_varbindsdecode'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  varbindsdecode [{ 'parmid' => 'theParmId', 'decode' => [{ 'varbindvalue' => 'theVarBindValue', 'varbinddecodedstring' => 'theVarBindDecodedString' }] }]
end
