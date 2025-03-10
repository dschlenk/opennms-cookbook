include_recipe 'opennms_resource_tests::wallboard'

opennms_dashlet 'summary2' do
  wallboard 'schlazorboard'
  dashlet_name 'Summary'
  parameters 'timeslot' => '3600', 'param2' => 'twelve'
end

# no parameters
opennms_dashlet 'summary3' do
  wallboard 'schlazorboard'
  dashlet_name 'Summary'
end

opennms_dashlet 'rtc' do
  wallboard 'schlazorboard'
  dashlet_name 'RTC'
end
