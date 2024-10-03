include_recipe 'opennms_resource_tests::dashlet'
opennms_dashlet 'update summary2' do
  title 'summary2'
  wallboard 'schlazorboard'
  dashlet_name 'RTC'
  notifies :restart, 'service[opennms]'
end
