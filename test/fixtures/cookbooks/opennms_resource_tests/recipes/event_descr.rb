# frozen_string_literal: true

include_recipe 'opennms_resource_tests::event'

# test update descr
opennms_event 'change descr of thresholdExceeded2' do
  uei 'uei.opennms.org/cheftest/thresholdExceeded2-event_descr'
  mask [{ 'mename' => 'id', 'mevalue' => ['.1.3.6.1.4.1.11385.102.1'] }, { 'mename' => 'generic', 'mevalue' => ['6'] }, { 'mename' => 'specific', 'mevalue' => ['2'] }]
  source_name 'events/chef.events.xml'
  descr '<p>A thresholds defined by a chef recipe has been exceeded.</p>'
end
