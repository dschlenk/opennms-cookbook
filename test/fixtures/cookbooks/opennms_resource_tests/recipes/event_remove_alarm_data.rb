# frozen_string_literal: true

include_recipe 'opennms_resource_tests::event'

# test remove alarm_data
opennms_event 'remove alarm_data of TE2' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_remove_alarm_data'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  alarm_data false
end
