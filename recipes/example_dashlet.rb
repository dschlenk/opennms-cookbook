opennms_dashlet 'summary2' do
  wallboard 'schlazorboard'
  dashlet_name 'Summary'
  parameters "timeslot" => "3600"
  notifies :restart, 'service[opennms]'
end
