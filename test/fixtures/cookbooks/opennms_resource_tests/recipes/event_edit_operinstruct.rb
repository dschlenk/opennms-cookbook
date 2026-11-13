# frozen_string_literal: true

include_recipe 'opennms_resource_tests::event'

opennms_event 'edit operinstruct' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_edit_operinstruct'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  operinstruct 'the operinstructed'
end
