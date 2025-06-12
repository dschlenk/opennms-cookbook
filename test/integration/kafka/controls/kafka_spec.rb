describe file('/opt/opennms/etc/org.opennms.features.kafka.producer.client.cfg') do
  its('content') { should include 'bootstrap.servers=127.0.0.1:9092' }
end

describe file('/opt/opennms/etc/org.opennms.features.kafka.producer.cfg') do
  its('content') { should include 'eventTopic=events' }
  its('content') { should include 'alarmTopic=alarms' }
  its('content') { should include 'alarmFeedbackTopic=alarmFeedback' }
  its('content') { should include 'nodeTopic=nodes' }
  its('content') { should include 'topologyVertexTopic=vertices' }
  its('content') { should include 'topologyEdgeTopic=edges' }
  its('content') { should include 'metricTopic=metrics' }
  its('content') { should include 'eventFilter=' }
  its('content') { should include 'alarmFilter=' }
  its('content') { should include 'forward.metrics=false' }
  its('content') { should include 'nodeRefreshTimeoutMs=300000' }
  its('content') { should include 'alarmSyncIntervalMs=300000' }
  its('content') { should include 'suppressIncrementalAlarms=true' }
  its('content') { should include 'kafkaSendQueueCapacity=1000' }
  its('content') { should include 'startAlarmSyncWithCleanState=false' }
end

describe file('/opt/opennms/etc/featuresBoot.d/kafka_producer.boot') do
  its('content') { should include 'opennms-kafka-producer' }
end

# compel an event on a node to cause the nodes topic to get published to
describe command('/opt/opennms/bin/send-event.pl --nodeid 1 --interface 127.0.0.1  uei.opennms.org/test') do
  its('exit_status') { should eq  0 }
end

describe command('/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server 127.0.0.1:9092') do
  its('stdout') { should match(/^alarms$/) }
  its('stdout') { should match(/^events$/) }
  its('stdout') { should match(/^nodes$/) }
end
