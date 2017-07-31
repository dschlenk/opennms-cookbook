# frozen_string_literal: true
include_recipe 'onms_lwrp_test::notification'
opennms_notification 'example2Broken' do
  status 'off'
  uei 'example2/exampleBroken'
  destination_path 'Email-Admin'
  text_message 'broken'
  action :delete
end
