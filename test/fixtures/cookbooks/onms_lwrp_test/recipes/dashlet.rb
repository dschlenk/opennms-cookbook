opennms_dashlet 'summary2' do
  wallboard 'schlazorboard'
  dashlet_name 'Summary'
  parameters "timeslot" => "3600"
  # dashboard config get read only once unless editied via WebUI
  notifies :restart, 'service[opennms]'
end
