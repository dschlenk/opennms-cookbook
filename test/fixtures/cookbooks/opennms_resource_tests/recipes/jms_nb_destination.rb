# frozen_string_literal: true
node.default['opennms']['plugin']['addl'] << 'opennms-plugin-northbounder-jms'

opennms_jms_nb_destination 'foo' do
  destination 'foo'
  first_occurrence_only true
  send_as_object_message false
  destination_type 'QUEUE'
  message_format 'ALARM ID:${alarmId} NODE:${nodeLabel}; ${logMsg}'
  action :create
end

opennms_jms_nb_destination 'bar' do
  destination 'bar'
  first_occurrence_only false
  send_as_object_message true
  destination_type 'TOPIC'
  message_format 'ALARM: ${logMsg}'
  action :create
end

opennms_jms_nb_destination 'baz' do
  destination 'baz'
  first_occurrence_only false
  send_as_object_message false
  destination_type 'QUEUE'
  message_format 'ALARM ID:${alarmId} - ${logMsg}'
  action :create
end

opennms_jms_nb_destination 'delete' do
  destination 'delete'
  action :delete
end
