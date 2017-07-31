# frozen_string_literal: true
include_recipe 'onms_lwrp_test::notification'
opennms_notification 'example2Broken' do
  status 'off'
  uei 'changedTheUei'
  destination_path 'Email-Admin'
  text_message 'broken'
end
