# frozen_string_literal: true
include_recipe 'onms_lwrp_test::dashlet'
opennms_dashlet 'update summary2' do
  title 'summary2'
  wallboard 'schlazorboard'
  dashlet_name 'RTC'
  notifies :restart, 'service[opennms]'
end
