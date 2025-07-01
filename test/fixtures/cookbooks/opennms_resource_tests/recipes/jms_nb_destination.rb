# frozen_string_literal: true

opennms_jms_nb_destination 'minimal-queue'

opennms_jms_nb_destination 'full-topic' do
  first_occurence_only true
  send_as_object_message true
  destination_type 'TOPIC'
  message_format 'ALARM: ${logMsg}'
end

opennms_jms_nb_destination 'another-queue' do
  first_occurence_only false
  send_as_object_message false
  destination_type 'QUEUE'
  message_format 'ALARM ID:${alarmId} - ${logMsg}'
end

opennms_jms_nb_destination 'create-if-missing-destination' do
  first_occurence_only true
  send_as_object_message false
  destination_type 'QUEUE'
  message_format 'ALARM: ${logMsg}'
  action :create_if_missing
end

opennms_jms_nb_destination 'delete-this-destination' do
  action :delete
end
