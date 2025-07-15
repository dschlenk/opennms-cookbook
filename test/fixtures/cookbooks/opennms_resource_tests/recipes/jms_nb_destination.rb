# frozen_string_literal: true
node.default['opennms']['plugin']['addl'] << 'opennms-plugin-northbounder-jms'

opennms_jms_nb_destination 'minimal-queue' do
  destination 'minimal-queue'
  action :create
end

opennms_jms_nb_destination 'full-topic' do
  destination 'full-topic'
  first_occurrence_only true
  send_as_object_message true
  destination_type 'TOPIC'
  message_format 'ALARM: ${logMsg}'
  action :create
end

opennms_jms_nb_destination 'another-queue' do
  destination 'another-queue'
  first_occurrence_only false
  send_as_object_message false
  destination_type 'QUEUE'
  message_format 'ALARM ID:${alarmId} - ${logMsg}'
  action :create
end

opennms_jms_nb_destination 'create-if-missing-destination' do
  destination 'create-if-missing-destination'
  first_occurrence_only true
  send_as_object_message false
  destination_type 'QUEUE'
  message_format 'ALARM: ${logMsg}'
  action :create_if_missing
end

opennms_jms_nb_destination 'delete-this-destination' do
  destination 'delete-this-destination'
  action :delete
end
