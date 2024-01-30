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

 describe file('/opt/opennms/etc/org.apache.karaf.features.cfg') do
   its('content') { should include 'opennms-kafka-producer' }
 end
