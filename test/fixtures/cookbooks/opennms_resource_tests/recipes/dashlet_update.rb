include_recipe 'opennms_resource_tests::dashlet'
opennms_dashlet 'update summary2' do
  title 'summary2'
  wallboard 'schlazorboard'
  boost_priority 3
  boost_duration 4
  priority 6
  duration 7
  dashlet_name 'RTC'
  parameters({})
end

opennms_dashlet 'delete summary3' do
  title 'summary3'
  wallboard 'schlazorboard'
  action :delete
end

opennms_dashlet 'noop rtc' do
  title 'rtc'
  wallboard 'schlazorboard'
  parameters 'timeslot' => '3600'
  action :create_if_missing
end
