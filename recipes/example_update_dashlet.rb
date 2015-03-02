opennms_dashlet 'summary2' do
  wallboard 'schlazorboard'
  dashlet_name 'RTC'
  notifies :restart, 'service[opennms]'
end
