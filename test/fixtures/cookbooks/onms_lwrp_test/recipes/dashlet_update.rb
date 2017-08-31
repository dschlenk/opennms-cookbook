# frozen_string_literal: true
include_recipe 'onms_lwrp_test::dashlet'
opennms_dashlet 'summary2' do
  wallboard 'schlazorboard'
  dashlet_name 'RTC'
  notifies :restart, 'service[opennms]'
end
