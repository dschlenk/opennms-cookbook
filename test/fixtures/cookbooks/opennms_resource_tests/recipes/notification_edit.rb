include_recipe 'opennms_resource_tests::notification'
opennms_notification 'example2Broken' do
  status 'off'
  uei 'changedTheUei'
  destination_path 'Email-Admin'
  text_message 'broken'
end
