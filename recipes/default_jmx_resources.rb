opennms_jmx_collection 'jsr160'
opennms_jmx_mbean 'OpenNMS Queued' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Queued'
  attribs(
    'CreatesCompleted' => { 'alias' => 'ONMSQueCreates', 'type' => 'counter' },
    'DequeuedItems' => { 'alias' => 'ONMSQueItemDeque', 'type' => 'counter' },
    'DequeuedOperations' => { 'alias' => 'ONMSQueDequeOps', 'type' => 'counter' },
    'EnqueuedOperations' => { 'alias' => 'ONMSQueEnqueOps', 'type' => 'counter' },
    'Errors' => { 'alias' => 'ONMSQueErrors', 'type' => 'counter' },
    'PromotionCount' => { 'alias' => 'ONMSQuePromo', 'type' => 'counter' },
    'SignificantOpsCompleted' => { 'alias' => 'ONMSQueSigOpsCompl', 'type' => 'counter' },
    'SignificantOpsDequeued' => { 'alias' => 'ONMSQueSigOpsDeque', 'type' => 'counter' },
    'SignificantOpsEnqueued' => { 'alias' => 'ONMSQueSigOpsEnque', 'type' => 'counter' },
    'TotalOperationsPending' => { 'alias' => 'ONMSQueOpsPend', 'type' => 'gauge' },
    'UpdatesCompleted' => { 'alias' => 'ONMSQueUpdates', 'type' => 'counter' }
  )
end

opennms_jmx_mbean 'OpenNMS Pollerd' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Pollerd'
  attribs(
    'NumPolls' => { 'alias' => 'ONMSPollCount', 'type' => 'counter' },
    'NumPoolThreads' => { 'alias' => 'ONMSPollerPoolThrd', 'type' => 'gauge' },
    'CorePoolThreads' => { 'alias' => 'ONMSPollerPoolCore', 'type' => 'gauge' },
    'MaxPoolThreads' => { 'alias' => 'ONMSPollerPoolMax', 'type' => 'gauge' },
    'PeakPoolThreads' => { 'alias' => 'ONMSPollerPoolPeak', 'type' => 'gauge' },
    'ActiveThreads' => { 'alias' => 'ONMSPollerThreadAct', 'type' => 'gauge' },
    'TasksTotal' => { 'alias' => 'ONMSPollerTasksTot', 'type' => 'counter' },
    'TasksCompleted' => { 'alias' => 'ONMSPollerTasksCpt', 'type' => 'counter' },
    'TaskQueuePendingCount' => { 'alias' => 'ONMSPollerTskQPCnt', 'type' => 'gauge' },
    'TaskQueueRemainingCapacity' => { 'alias' => 'ONMSPollerTskQRCap', 'type' => 'gauge' },
    'NumPollsInFlight' => { 'alias' => 'ONMSPollsInFlight', 'type' => 'gauge' }
  )
end

opennms_jmx_mbean 'org.opennms.core.ipc.sink.kafka.heartbeat' do
  collection_name 'jsr160'
  resource_type 'kafkaLag'
  objectname 'org.opennms.core.ipc.sink.kafka:name=*.Lag,type=gauges'
  attribs(
    'Value' => { 'alias' => 'Lag', 'type' => 'gauge' }
  )
end

opennms_jmx_mbean 'OpenNMS Vacuumd' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Vacuumd'
  attribs(
    'NumAutomations' => { 'alias' => 'ONMSAutomCount', 'type' => 'counter' }
  )
end

opennms_jmx_mbean 'OpenNMS Collectd' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Collectd'
  attribs(
    'ActiveThreads' => { 'alias' => 'ONMSCollectThrdAct', 'type' => 'gauge' },
    'NumPoolThreads' => { 'alias' => 'ONMSCollectPoolThrd', 'type' => 'gauge' },
    'CorePoolThreads' => { 'alias' => 'ONMSCollectPoolCore', 'type' => 'gauge' },
    'MaxPoolThreads' => { 'alias' => 'ONMSCollectPoolMax', 'type' => 'gauge' },
    'PeakPoolThreads' => { 'alias' => 'ONMSCollectPoolPeak', 'type' => 'gauge' },
    'TasksTotal' => { 'alias' => 'ONMSCollectTasksTot', 'type' => 'counter' },
    'TasksCompleted' => { 'alias' => 'ONMSCollectTasksCpt', 'type' => 'counter' },
    'CollectableServiceCount' => { 'alias' => 'ONMSCollectSvcCount', 'type' => 'gauge' },
    'TaskQueuePendingCount' => { 'alias' => 'ONMSCollectTskQPCnt', 'type' => 'gauge' },
    'TaskQueueRemainingCapacity' => { 'alias' => 'ONMSCollectTskQRCap', 'type' => 'gauge' }
  )
end

opennms_jmx_mbean 'OpenNMS.JettyServer' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=JettyServer'
  attribs(
    'HttpsConnectionsTotal' => { 'alias' => 'HttpsConnTotal', 'type' => 'counter' },
    'HttpsConnectionsOpen' => { 'alias' => 'HttpsConnOpen', 'type' => 'gauge' },
    'HttpsConnectionsOpenMax' => { 'alias' => 'HttpsConnOpenMax', 'type' => 'gauge' },
    'HttpConnectionsTotal' => { 'alias' => 'HttpConnTotal', 'type' => 'counter' },
    'HttpConnectionsOpen' => { 'alias' => 'HttpConnOpen', 'type' => 'gauge' },
    'HttpConnectionsOpenMax' => { 'alias' => 'HttpConnOpenMax', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'OpenNMS.Statsd' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Statsd'
  attribs(
    'ReportsStarted' => { 'alias' => 'StaReportsStarted', 'type' => 'counter' },
    'ReportsCompleted' => { 'alias' => 'StaReportsCompleted', 'type' => 'counter' },
    'ReportsPersisted' => { 'alias' => 'StaReportsPersisted', 'type' => 'counter' },
    'ReportRunTime' => { 'alias' => 'StaReportRunTime', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'OpenNMS.Trapd' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Trapd'
  attribs(
    'TrapsDiscarded' => { 'alias' => 'TrapsDiscarded', 'type' => 'counter' },
    'TrapsErrored' => { 'alias' => 'TrapsErrored', 'type' => 'counter' },
    'V1TrapsReceived' => { 'alias' => 'V1TrapsReceived', 'type' => 'counter' },
    'V2cTrapsReceived' => { 'alias' => 'V2cTrapsReceived', 'type' => 'counter' },
    'V3TrapsReceived' => { 'alias' => 'V3TrapsReceived', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'OpenNMS.Notifd' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Notifd'
  attribs(
    'NotificationTasksQueued' => { 'alias' => 'NotificTasksQueued', 'type' => 'counter' },
    'BinaryNoticesAttempted' => { 'alias' => 'BinaryNoticeAttemp', 'type' => 'counter' },
    'JavaNoticesAttempted' => { 'alias' => 'JavaNoticesAttempt', 'type' => 'counter' },
    'BinaryNoticesSucceeded' => { 'alias' => 'BinaryNoticeSuccee', 'type' => 'counter' },
    'JavaNoticesSucceeded' => { 'alias' => 'JavaNoticesSucceed', 'type' => 'counter' },
    'BinaryNoticesFailed' => { 'alias' => 'BinaryNoticeFailed', 'type' => 'counter' },
    'JavaNoticesFailed' => { 'alias' => 'JavaNoticesFailed', 'type' => 'counter' },
    'BinaryNoticesInterrupted' => { 'alias' => 'BinaryNoticeInterr', 'type' => 'counter' },
    'JavaNoticesInterrupted' => { 'alias' => 'JavaNoticesInterru', 'type' => 'counter' },
    'UnknownNoticesInterrupted' => { 'alias' => 'UnknowNoticeInterr', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'OpenNMS.Manager' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Manager'
  attribs(
    'onmsUptime' => { 'alias' => 'Uptime', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'JVM Memory' do
  collection_name 'jsr160'
  objectname 'java.lang:type=OperatingSystem'
  attribs(
    'FreePhysicalMemorySize' => { 'alias' => 'FreeMemory', 'type' => 'gauge' },
    'TotalPhysicalMemorySize' => { 'alias' => 'TotalMemory', 'type' => 'gauge' },
    'FreeSwapSpaceSize' => { 'alias' => 'FreeSwapSpace', 'type' => 'gauge' },
    'TotalSwapSpaceSize' => { 'alias' => 'TotalSwapSpace', 'type' => 'gauge' },
    'MaxFileDescriptorCount' => { 'alias' => 'OsMaxFDCount', 'type' => 'gauge' },
    'OpenFileDescriptorCount' => { 'alias' => 'OsOpenFDCount', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'Heap Memory' do
  collection_name 'jsr160'
  objectname 'java.lang:type=Memory'
  comp_attribs(
    'HeapMemoryUsage' => { 'alias' => 'HeapUsed', 'type' => 'Composite', 'comp_members' => {
      'init' => { 'alias' => 'HeapUsageInit', 'type' => 'gauge' },
      'max' => { 'alias' => 'HeapUsageMax', 'type' => 'gauge' },
      'used' => { 'alias' => 'HeapUsageUsed', 'type' => 'gauge' },
      'committed' => { 'alias' => 'HeapUsgCmmttd', 'type' => 'gauge' },
      }
    }
  )
end
opennms_jmx_mbean 'JVM Threading' do
  collection_name 'jsr160'
  objectname 'java.lang:type=Threading'
  attribs(
    'ThreadCount' => { 'alias' => 'ThreadCount', 'type' => 'gauge' },
    'PeakThreadCount' => { 'alias' => 'PeakThreadCount', 'type' => 'gauge' },
    'DaemonThreadCount' => { 'alias' => 'DaemonThreadCount', 'type' => 'gauge' },
    'CurrentThreadCpuTime' => { 'alias' => 'CurThreadCpuTime', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'JVM ClassLoading' do
  collection_name 'jsr160'
  objectname 'java.lang:type=ClassLoading'
  attribs(
    'TotalLoadedClassCount' => { 'alias' => 'TotLoadedClasses', 'type' => 'gauge' },
    'LoadedClassCount' => { 'alias' => 'LoadedClasses', 'type' => 'gauge' },
    'UnloadedClassCount' => { 'alias' => 'UnloadedClass', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'JVM MemoryPool:Eden Space' do
  collection_name 'jsr160'
  objectname 'java.lang:type=MemoryPool,name=*Eden Space'
  attribs(
    'CollectionUsageThreshold' => { 'alias' => 'EdenCollUseThrsh', 'type' => 'gauge' },
    'CollectionUsageThresholdCount' => { 'alias' => 'EdenCollUseThrshCnt', 'type' => 'gauge' }
  )
  comp_attribs(
    'Usage' => { 'alias' => 'EdenUsage', 'type' => 'Composite', 'comp_members' => {
      'init' => { 'alias' => 'EdenUsageInit', 'type' => 'gauge' },
      'max' => { 'alias' => 'EdenUsageMax', 'type' => 'gauge' },
      'used' => { 'alias' => 'EdenUsageUsed', 'type' => 'gauge' },
      'committed' => { 'alias' => 'EdenUsgCmmttd', 'type' => 'gauge' } } },
    'PeakUsage' => { 'alias' => 'EdenPeakUsage', 'type' => 'Composite', 'comp_members' => {
      'init' => { 'alias' => 'EdenPeakUsageInit', 'type' => 'gauge' },
      'max' => { 'alias' => 'EdenPeakUsageMax', 'type' => 'gauge' },
      'used' => { 'alias' => 'EdenPeakUsageUsed', 'type' => 'gauge' },
      'committed' => { 'alias' => 'EdenPeakUsgCmmttd', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM MemoryPool:Survivor Space' do
  collection_name 'jsr160'
  objectname 'java.lang:type=MemoryPool,name=*Survivor Space'
  attribs(
    'CollectionUsageThreshold' => { 'alias' => 'SurvCollUseThresh', 'type' => 'gauge' },
    'CollectionUsageThresholdCount' => { 'alias' => 'SurvCollUseThrshCnt', 'type' => 'gauge' }
  )
  comp_attribs(
    'Usage' => { 'alias' => 'SurvUsage', 'type' => 'Composite', 'comp_members' => {
      'init' => { 'alias' => 'SurvUsageInit', 'type' => 'gauge' },
      'max' => { 'alias' => 'SurvUsageMax', 'type' => 'gauge' },
      'used' => { 'alias' => 'SurvUsageUsed', 'type' => 'gauge' },
      'committed' => { 'alias' => 'SurvUsgCmmttd', 'type' => 'gauge' } } },
    'PeakUsage' => { 'alias' => 'SurvPeakUsage', 'type' => 'Composite', 'comp_members' => {
      'init' => { 'alias' => 'SurvPeakUsageInit', 'type' => 'gauge' },
      'max' => { 'alias' => 'SurvPeakUsageMax', 'type' => 'gauge' },
      'used' => { 'alias' => 'SurvPeakUsageUsed', 'type' => 'gauge' },
      'committed' => { 'alias' => 'SurvPeakUsgCmmttd', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM MemoryPool:Perm Gen' do
  collection_name 'jsr160'
  objectname 'java.lang:type=MemoryPool,name=Perm Gen'
  attribs(
  'CollectionUsageThreshold' => { 'alias' => 'PermCollUseThresh', 'type' => 'gauge' },
  'CollectionUsageThresholdCount' => { 'alias' => 'PermCollUseThrshCnt', 'type' => 'gauge' }
)
  comp_attribs(
  'Usage' => { 'alias' => 'PermUsage', 'type' => 'Composite', 'comp_members' => {
    'init' => { 'alias' => 'PermUsageInit', 'type' => 'gauge' },
    'max' => { 'alias' => 'PermUsageMax', 'type' => 'gauge' },
    'used' => { 'alias' => 'PermUsageUsed', 'type' => 'gauge' },
    'committed' => { 'alias' => 'PermUsgCmmttd', 'type' => 'gauge' } } }
)
end
opennms_jmx_mbean 'JVM MemoryPool:Metaspace' do
  collection_name 'jsr160'
  objectname 'java.lang:type=MemoryPool,name=Metaspace'
  attribs(
    'CollectionUsageThreshold' => { 'alias' => 'MetaCollUseThresh', 'type' => 'gauge' },
    'CollectionUsageThresholdCount' => { 'alias' => 'MetaCollUseThrshCnt', 'type' => 'gauge' }
  )
  comp_attribs(
  'Usage' => { 'alias' => 'MetaUsage', 'type' => 'Composite', 'comp_members' => {
    'init' => { 'alias' => 'MetaUsageInit', 'type' => 'gauge' },
    'max' => { 'alias' => 'MetaUsageMax', 'type' => 'gauge' },
    'used' => { 'alias' => 'MetaUsageUsed', 'type' => 'gauge' },
    'committed' => { 'alias' => 'MetaUsgCmmttd', 'type' => 'gauge' } } }
)
end
opennms_jmx_mbean 'JVM MemoryPool:Old Gen' do
  collection_name 'jsr160'
  objectname 'java.lang:type=MemoryPool,name=*Old Gen'
  attribs(
    'CollectionUsageThreshold' => { 'alias' => 'OGenCollUseThresh', 'type' => 'gauge' },
    'CollectionUsageThresholdCount' => { 'alias' => 'OGenCollUseThrshCnt', 'type' => 'gauge' }
  )
  comp_attribs(
  'Usage' => { 'alias' => 'OGenUsage', 'type' => 'Composite', 'comp_members' => {
    'init' => { 'alias' => 'OGenUsageInit', 'type' => 'gauge' },
    'max' => { 'alias' => 'OGenUsageMax', 'type' => 'gauge' },
    'used' => { 'alias' => 'OGenUsageUsed', 'type' => 'gauge' },
    'committed' => { 'alias' => 'OGenUsgCmmttd', 'type' => 'gauge' } } }
)
end
opennms_jmx_mbean 'JVM GarbageCollector:Copy' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=Copy'
  attribs(
    'CollectionCount' => { 'alias' => 'CopyCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'CopyCollTime', 'type' => 'counter' }
  )
  comp_attribs(
  'LastGcInfo' => { 'alias' => 'CopyLastGcInfo', 'type' => 'Composite', 'comp_members' => {
    'GcThreadCount' => { 'alias' => 'CopyGcThreadCnt', 'type' => 'gauge' },
    'duration' => { 'alias' => 'CopyDuration', 'type' => 'gauge' },
    'endTime' => { 'alias' => 'CopyEndTime', 'type' => 'gauge' } } }
)
end
opennms_jmx_mbean 'JVM GarbageCollector:MarkSweepCompact' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=MarkSweepCompact'
  attribs(
    'CollectionCount' => { 'alias' => 'MSCCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'MSCCollTime', 'type' => 'counter' }
  )
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'MSCLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'MSCGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'MSCDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'MSCEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM GarbageCollector:ParNew' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=ParNew'
  attribs(
    'CollectionCount' => { 'alias' => 'ParNewCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'ParNewCollTime', 'type' => 'counter' }
  )
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'ParNewLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'ParNewGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'ParNewDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'ParNewEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM GarbageCollector:ConcurrentMarkSweep' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=ConcurrentMarkSweep'
  attribs(
    'CollectionCount' => { 'alias' => 'CMSCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'CMSCollTime', 'type' => 'counter' }
  )
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'CMSLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'CMSGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'CMSDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'CMSEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM GarbageCollector:PS MarkSweep' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=PS MarkSweep'
  attribs(
    'CollectionCount' => { 'alias' => 'PSMSCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'PSMSCollTime', 'type' => 'counter' }
  )
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'PSMSLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'PSMSGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'PSMSDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'PSMSEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM GarbageCollector:PS Scavenge' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=PS Scavenge'
  attribs(
    'CollectionCount' => { 'alias' => 'PSSCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'PSSCollTime', 'type' => 'counter' }
  )
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'PSSLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'PSSGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'PSSDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'PSSEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM GarbageCollector:G1 Old Generation' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=G1 Old Generation'
  attribs(
  'CollectionCount' => { 'alias' => 'G1OldCollCnt', 'type' => 'counter' },
  'CollectionTime' => { 'alias' => 'G1OldCollTime', 'type' => 'counter' }
)
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'G1OldLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'G1OldGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'G1OldDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'G1OldEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'JVM GarbageCollector:G1 Young Generation' do
  collection_name 'jsr160'
  objectname 'java.lang:type=GarbageCollector,name=G1 Young Generation'
  attribs(
    'CollectionCount' => { 'alias' => 'G1YngCollCnt', 'type' => 'counter' },
    'CollectionTime' => { 'alias' => 'G1YngCollTime', 'type' => 'counter' }
  )
  comp_attribs(
    'LastGcInfo' => { 'alias' => 'G1YngLastGcInfo', 'type' => 'Composite', 'comp_members' => {
      'GcThreadCount' => { 'alias' => 'G1YngGcThreadCnt', 'type' => 'gauge' },
      'duration' => { 'alias' => 'G1YngDuration', 'type' => 'gauge' },
      'endTime' => { 'alias' => 'G1YngEndTime', 'type' => 'gauge' } } }
  )
end
opennms_jmx_mbean 'org.opennms.newts.ring-buffer.size' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=ring-buffer.size,type=gauges'
  attribs(
    'Value' => { 'alias' => 'NewtsRingBufSize', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.ring-buffer.max-size' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=ring-buffer.max-size,type=gauges'
  attribs(
    'Value' => { 'alias' => 'NewtsRingBufMaxSize', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.cache.size' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=cache.size,type=gauges'
  attribs(
    'Value' => { 'alias' => 'NewtsCacheSize', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.cache.max-size' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=cache.max-size,type=gauges'
  attribs(
    'Value' => { 'alias' => 'NewtsMaxCacheSize', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.repository.insert-timer' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=repository.insert-timer,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'NewtsInsert50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'NewtsInsert75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'NewtsInsert95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'NewtsInsert98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'NewtsInsert99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'NewtsInsert999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'NewtsInsertCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.repository.measurement-select-timer' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=repository.measurement-select-timer,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'NewtsMeasSelct50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'NewtsMeasSelct75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'NewtsMeasSelct95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'NewtsMeasSelct98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'NewtsMeasSelct99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'NewtsMeasSelct999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'NewtsMeasSelctCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.repository.sample-select-timer' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=repository.sample-select-timer,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'NewtsSmplSelct50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'NewtsSmplSelct75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'NewtsSmplSelct95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'NewtsSmplSelct98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'NewtsSmplSelct99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'NewtsSmplSelct999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'NewtsSmplSelctCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.repository.samples-inserted' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=repository.samples-inserted,type=meters'
  attribs(
    'Count' => { 'alias' => 'NewtsSmplsInsertd', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.repository.samples-selected' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=repository.samples-selected,type=meters'
  attribs(
    'Count' => { 'alias' => 'NewtsSmplsSelctd', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.search.update' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=search.update,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'NewtsSearchUpd50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'NewtsSearchUpd75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'NewtsSearchUpd95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'NewtsSearchUpd98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'NewtsSearchUpd99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'NewtsSearchUpd999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'NewtsSearchUpdCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.search.delete' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=search.delete,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'NewtsSearchDel50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'NewtsSearchDel75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'NewtsSearchDel95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'NewtsSearchDel98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'NewtsSearchDel99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'NewtsSearchDel999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'NewtsSearchDelCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.newts.search.inserts' do
  collection_name 'jsr160'
  objectname 'org.opennms.newts:name=search.inserts,type=meters'
  attribs(
    'Count' => { 'alias' => 'NewtsSearchInserts', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'cluster1-metrics.requests' do
  collection_name 'jsr160'
  objectname 'cluster1-metrics:name=requests'
  attribs(
    '50thPercentile' => { 'alias' => 'CasCluster1Req50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'CasCluster1Req75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'CasCluster1Req95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'CasCluster1Req98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'CasCluster1Req99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'CasCluster1Req999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'CasCluster1ReqCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.apache.activemq' do
  collection_name 'jsr160'
  objectname 'org.apache.activemq:type=Broker,brokerName=localhost'
  attribs(
    'TotalConnectionsCount' => { 'alias' => 'TtlConCnt', 'type' => 'counter' },
    'TotalEnqueueCount' => { 'alias' => 'TtlEnqCnt', 'type' => 'counter' },
    'TotalDequeueCount' => { 'alias' => 'TtlDeqCnt', 'type' => 'counter' },
    'TotalConsumerCount' => { 'alias' => 'TtlConsumerCnt', 'type' => 'gauge' },
    'TotalProducerCount' => { 'alias' => 'TtlProdCnt', 'type' => 'gauge' },
    'TotalMessageCount' => { 'alias' => 'TtlMsgCnt', 'type' => 'counter' },
    'AverageMessageSize' => { 'alias' => 'AvgMsgSize', 'type' => 'gauge' },
    'MaxMessageSize' => { 'alias' => 'MaxMsgSize', 'type' => 'gauge' },
    'MinMessageSize' => { 'alias' => 'MinMsgSize', 'type' => 'gauge' },
    'MemoryLimit' => { 'alias' => 'MemLimit', 'type' => 'gauge' },
    'MemoryPercentUsage' => { 'alias' => 'MemPctUsage', 'type' => 'gauge' },
    'StoreLimit' => { 'alias' => 'StoreLimit', 'type' => 'gauge' },
    'StorePercentUsage' => { 'alias' => 'StorePctUsage', 'type' => 'gauge' },
    'TempLimit' => { 'alias' => 'TempLimit', 'type' => 'gauge' },
    'TempPercentUsage' => { 'alias' => 'TempPctUsage', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.apache.activemq' do
  resource_type 'queueMetrics'
  collection_name 'jsr160'
  objectname 'org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=*'
  attribs(
    'DequeueCount' => { 'alias' => 'DequeCnt', 'type' => 'counter' },
    'EnqueueCount' => { 'alias' => 'EnqueCnt', 'type' => 'counter' },
    'BlockedSends' => { 'alias' => 'BlkdSends', 'type' => 'gauge' },
    'MemoryPercentUsage' => { 'alias' => 'MemPctUsage', 'type' => 'gauge' },
    'MemoryLimit' => { 'alias' => 'MemLimit', 'type' => 'gauge' },
    'AverageEnqueueTime' => { 'alias' => 'AvgEnQTime', 'type' => 'gauge' },
    'MaxEnqueueTime' => { 'alias' => 'MaxtEnQTime', 'type' => 'gauge' },
    'MinEnqueueTime' => { 'alias' => 'MintEnQTime', 'type' => 'gauge' },
    'QueueSize' => { 'alias' => 'DestQsize', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.flows.flowsPersisted' do
  collection_name 'jsr160'
  objectname 'org.opennms.netmgt.flows:name=flowsPersisted,type=meters'
  attribs(
    'Count' => { 'alias' => 'FlowPerst', 'type' => 'counter' },
    'OneMinuteRate' => { 'alias' => 'FlowPerst1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'FlowPerst5m', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.flows.flowsPerLog' do
  collection_name 'jsr160'
  objectname 'org.opennms.netmgt.flows:name=flowsPerLog,type=histograms'
  attribs(
    '50thPercentile' => { 'alias' => 'FlowFlwsPerLog50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'FlowFlwsPerLog75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'FlowFlwsPerLog95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'FlowFlwsPerLog98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'FlowFlwsPerLog99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'FlowFlwsPerLog999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'FlowFlwsPerLogCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.flows.logEnrichment' do
  collection_name 'jsr160'
  objectname 'org.opennms.netmgt.flows:name=logEnrichment,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'FlowLogEnrich50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'FlowLogEnrich75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'FlowLogEnrich95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'FlowLogEnrich98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'FlowLogEnrich99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'FlowLogEnrich999', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'FlowLogEnrich1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'FlowLogEnrich5m', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.flows.logPersisting' do
  collection_name 'jsr160'
  objectname 'org.opennms.netmgt.flows:name=logPersisting,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'FlowLogPerst50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'FlowLogPerst75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'FlowLogPerst95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'FlowLogPerst98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'FlowLogPerst99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'FlowLogPerst999', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'FlowLogPerst1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'FlowLogPerst5m', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.telemetry.adapters.packetsPerLog' do
  collection_name 'jsr160'
  resource_type 'telemetryAdapters'
  objectname 'org.opennms.netmgt.telemetry:name=adapters.*packetsPerLog,type=histograms'
  attribs(
    '50thPercentile' => { 'alias' => 'TlmPktsPerLog50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'TlmPktsPerLog75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'TlmPktsPerLog95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'TlmPktsPerLog98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'TlmPktsPerLog99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'TlmPktsPerLog999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'TlmPktsPerLogCnt', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.telemetry.adapters.logParsing' do
  collection_name 'jsr160'
  resource_type 'telemetryAdapters'
  objectname 'org.opennms.netmgt.telemetry:name=adapters.*logParsing,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'TlmLogParse50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'TlmLogParse75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'TlmLogParse95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'TlmLogParse98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'TlmLogParse99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'TlmLogParse999', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'TlmLogParse1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'TlmLogParse5m', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.telemetry.listeners.packetsReceived' do
  collection_name 'jsr160'
  resource_type 'telemetryListeners'
  objectname 'org.opennms.netmgt.telemetry:name=listeners.*packetsReceived,type=meters'
  attribs(
    'Count' => { 'alias' => 'TlmPacketsRcvd', 'type' => 'counter' },
    'OneMinuteRate' => { 'alias' => 'TlmPacketsRcvd1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'TlmPacketsRcvd5m', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.sink.producer.dispatch' do
  collection_name 'jsr160'
  resource_type 'sinkProducerMetrics'
  objectname 'org.opennms.core.ipc.sink.producer:name=*.dispatch,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'Dispatch50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'Dispatch75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'Dispatch95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'Dispatch98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'Dispatch99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'Dispatch999', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'DispatchRate1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'DispatchRate5m', 'type' => 'gauge' },
    'Count' => { 'alias' => 'DispatchCounter', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.sink.producer.queue-size' do
  collection_name 'jsr160'
  resource_type 'sinkProducerMetrics'
  objectname 'org.opennms.core.ipc.sink.producer:name=*.queue-size,type=gauges'
  attribs(
    'Value' => { 'alias' => 'QueueSize', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.sink.producer.dropped' do
  collection_name 'jsr160'
  resource_type 'sinkProducerMetrics'
  objectname 'org.opennms.core.ipc.sink.producer:name=*.dropped,type=counters'
  attribs(
    'Count' => { 'alias' => 'DroppedCounter', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.sink.consumer.dispatchTime' do
  collection_name 'jsr160'
  resource_type 'sinkConsumerMetrics'
  objectname 'org.opennms.core.ipc.sink.consumer:name=*.dispatchTime,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'DispatchTime50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'DispatchTime75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'DispatchTime95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'DispatchTime98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'DispatchTime99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'DispatchTime999', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'DispatchTimeRate1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'DispatchTimeRate5m', 'type' => 'gauge' },
    'Count' => { 'alias' => 'DispatchTimeCount', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.sink.consumer.messageSize' do
  collection_name 'jsr160'
  resource_type 'sinkConsumerMetrics'
  objectname 'org.opennms.core.ipc.sink.consumer:name=*.messageSize,type=histograms'
  attribs(
    '50thPercentile' => { 'alias' => 'MessageSize50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'MessageSize75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'MessageSize95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'MessageSize98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'MessageSize99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'MessageSize999', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.rpc.requestSent' do
  collection_name 'jsr160'
  resource_type 'rpcMetrics'
  objectname 'org.opennms.core.ipc.rpc:name=*.requestSent,type=meters'
  attribs(
    'FiveMinuteRate' => { 'alias' => 'RequestSentPer5Min', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.rpc.requestFailed' do
  collection_name 'jsr160'
  resource_type 'rpcMetrics'
  objectname 'org.opennms.core.ipc.rpc:name=*.requestFailed,type=meters'
  attribs(
    'FiveMinuteRate' => { 'alias' => 'RequestFailed5Min', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.rpc.requestSize' do
  collection_name 'jsr160'
  resource_type 'rpcMetrics'
  objectname 'org.opennms.core.ipc.rpc:name=*.requestSize,type=histograms'
  attribs(
    '50thPercentile' => { 'alias' => 'RequestSize50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'RequestSize75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'RequestSize95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'RequestSize98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'RequestSize99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'RequestSize999', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.rpc.responseSize' do
  collection_name 'jsr160'
  resource_type 'rpcMetrics'
  objectname 'org.opennms.core.ipc.rpc:name=*.responseSize,type=histograms'
  attribs(
    '50thPercentile' => { 'alias' => 'ResponseSize50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'ResponseSize75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'ResponseSize95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'ResponseSize98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'ResponseSize99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'ResponseSize999', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.rpc.duration' do
  collection_name 'jsr160'
  resource_type 'rpcMetrics'
  objectname 'org.opennms.core.ipc.rpc:name=*.duration,type=histograms'
  attribs(
    '50thPercentile' => { 'alias' => 'Duration50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'Duration75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'Duration95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'Duration98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'Duration99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'Duration999', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.twin.publisher.sinkUpdateSent' do
  collection_name 'jsr160'
  resource_type 'twinMetrics'
  objectname 'org.opennms.core.ipc.twin.publisher:name=*.sinkUpdateSent,type=counters'
  attribs(
    'Count' => { 'alias' => 'SinkUpdateSent', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.twin.publisher.sinkUpdateSent' do
  collection_name 'jsr160'
  resource_type 'twinMetrics'
  objectname 'org.opennms.core.ipc.twin.publisher:name=*.twinResponseSent,type=counters'
  attribs(
    'Count' => { 'alias' => 'TwinResponseSent', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.twin.publisher.twinEmptyResponseSent' do
  collection_name 'jsr160'
  resource_type 'twinMetrics'
  objectname 'org.opennms.core.ipc.twin.publisher:name=*.twinEmptyResponseSent,type=counters'
  attribs(
    'Count' => { 'alias' => 'TwinEmptyResponseSent', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.twin.subscriber.requestSent' do
  collection_name 'jsr160'
  resource_type 'twinMetrics'
  objectname 'org.opennms.core.ipc.twin.subscriber:name=*.requestSent,type=counters'
  attribs(
    'Count' => { 'alias' => 'RequestSent', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.twin.subscriber.updateReceived' do
  collection_name 'jsr160'
  resource_type 'twinMetrics'
  objectname 'org.opennms.core.ipc.twin.subscriber:name=*.updateReceived,type=counters'
  attribs(
    'Count' => { 'alias' => 'UpdateReceived', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.core.ipc.twin.subscriber.updateDropped' do
  collection_name 'jsr160'
  resource_type 'twinMetrics'
  objectname 'org.opennms.core.ipc.twin.subscriber:name=*.updateDropped,type=counters'
  attribs(
    'Count' => { 'alias' => 'UpdateDropped', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'drools.alarmd.facts' do
  collection_name 'jsr160'
  objectname 'org.opennms.features.drools.alarmd:name=facts,type=gauges'
  attribs(
    'Value' => { 'alias' => 'DroolsAlarmdFacts', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'drools.alarmd.actions' do
  collection_name 'jsr160'
  objectname 'org.opennms.features.drools.alarmd:name=atomicActionsInFlight,type=gauges'
  attribs(
    'Value' => { 'alias' => 'DroolsAlarmdActions', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'drools.alarmd.actions.queued' do
  collection_name 'jsr160'
  objectname 'org.opennms.features.drools.alarmd:name=atomicActionsQueued,type=meters'
  attribs(
    'OneMinuteRate' => { 'alias' => 'DroolsAlarmdActQu1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'DroolsAlarmdActQu5m', 'type' => 'gauge' },
    'Count' => { 'alias' => 'DroolsAlarmdActQu', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'drools.alarmd.alarms' do
  collection_name 'jsr160'
  objectname 'org.opennms.features.drools.alarmd:name=numAlarmsFromLastSnapshot,type=gauges'
  attribs(
    'Value' => { 'alias' => 'DroolsAlarmdAlarms', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'drools.alarmd.situations' do
  collection_name 'jsr160'
  objectname 'org.opennms.features.drools.alarmd:name=numSituationsFromLastSnapshot,type=gauges'
  attribs(
    'Value' => { 'alias' => 'DroolsAlarmdSitu', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'drools.alarmd.liveness' do
  collection_name 'jsr160'
  objectname 'org.opennms.features.drools.alarmd:name=liveness,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'DroolsAlarmdLv50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'DroolsAlarmdLv75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'DroolsAlarmdLv95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'DroolsAlarmdLv98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'DroolsAlarmdLv99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'DroolsAlarmdLv999', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'ALEC Graph Stats' do
  collection_name 'jsr160'
  resource_type 'ALECgraph'
  objectname 'org.opennms.alec.driver.main.Driver.dbscan:name=*,type=gauges'
  attribs(
    'Value' => { 'alias' => 'ALECgraphStat', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'ALEC Tick Stats' do
  collection_name 'jsr160'
  objectname 'org.opennms.alec.driver.main.Driver.dbscan:name=ticks,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'ALECtick50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'ALECtick75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'ALECtick95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'ALECtick98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'ALECtick99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'ALECtick999', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'ALECtickRate1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'ALECtickRate5m', 'type' => 'gauge' },
    'Max' => { 'alias' => 'ALECtickMax', 'type' => 'gauge' },
    'Min' => { 'alias' => 'ALECtickMin', 'type' => 'gauge' },
    'Count' => { 'alias' => 'ALECtickCounter', 'type' => 'counter' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.eventd.process' do
  collection_name 'jsr160'
  resource_type 'Eventlogs'
  objectname 'org.opennms.netmgt.eventd:name=eventlogs.process*,type=timers'
  attribs(
    '50thPercentile' => { 'alias' => 'EventProcess50', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'EventProcess75', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'EventProcess95', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'EventProcess98', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'EventProcess99', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'EventProcess999', 'type' => 'gauge' },
    'Count' => { 'alias' => 'EventProcessCount', 'type' => 'counter' },
    'Mean' => { 'alias' => 'EventProcessMean', 'type' => 'gauge' },
    'Max' => { 'alias' => 'EventProcessMax', 'type' => 'gauge' },
    'Min' => { 'alias' => 'EventProcessMin', 'type' => 'gauge' },
    'FifteenMinuteRate' => { 'alias' => 'EventProcessRate15m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'EventProcessRate5m', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'EventProcessRate1m', 'type' => 'gauge' },
    'MeanRate' => { 'alias' => 'EventProcessRate', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'org.opennms.netmgt.provision.overall' do
  collection_name 'jsr160'
  resource_type 'requisitionMetrics'
  objectname 'org.opennms.netmgt.provision.overall:name=*'
  attribs(
    '50thPercentile' => { 'alias' => 'Reqtn50th', 'type' => 'gauge' },
    '75thPercentile' => { 'alias' => 'Reqtn75th', 'type' => 'gauge' },
    '95thPercentile' => { 'alias' => 'Reqtn95th', 'type' => 'gauge' },
    '98thPercentile' => { 'alias' => 'Reqtn98th', 'type' => 'gauge' },
    '99thPercentile' => { 'alias' => 'Reqtn99th', 'type' => 'gauge' },
    '999thPercentile' => { 'alias' => 'Reqtn999th', 'type' => 'gauge' },
    'OneMinuteRate' => { 'alias' => 'Reqtn1m', 'type' => 'gauge' },
    'FiveMinuteRate' => { 'alias' => 'Reqtn5m', 'type' => 'gauge' },
    'FifteenMinuteRate' => { 'alias' => 'Reqtn15m', 'type' => 'gauge' },
    'Count' => { 'alias' => 'ReqtnCounter', 'type' => 'counter' },
    'Mean' => { 'alias' => 'ReqtnMean', 'type' => 'gauge' },
    'Max' => { 'alias' => 'ReqtnMax', 'type' => 'gauge' },
    'Min' => { 'alias' => 'ReqtnMin', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'OpenNMS Provisiond' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=Provisiond'
  attribs(
    'ImportActiveThreads' => { 'alias' => 'PvImprtThrdAct', 'type' => 'gauge' },
    'ImportNumPoolThreads' => { 'alias' => 'PvImprtPoolThrd', 'type' => 'gauge' },
    'ImportCorePoolThreads' => { 'alias' => 'PvImprtPoolCore', 'type' => 'gauge' },
    'ImportPeakPoolThreads' => { 'alias' => 'PvImprtPoolPeak', 'type' => 'gauge' },
    'ImportTasksTotal' => { 'alias' => 'PvImprtTasksTot', 'type' => 'counter' },
    'ImportTasksCompleted' => { 'alias' => 'PvImprtTasksCpt', 'type' => 'counter' },
    'ImportCollectableServiceCount' => { 'alias' => 'PvImprtSvcCount', 'type' => 'gauge' },
    'ImportTaskQueuePendingCount' => { 'alias' => 'PvImprtTskQPCnt', 'type' => 'gauge' },
    'ImportTaskQueueRemainingCapacity' => { 'alias' => 'PvImprtTskQRCap', 'type' => 'gauge' },
    'ScanActiveThreads' => { 'alias' => 'PvScanThrdAct', 'type' => 'gauge' },
    'ScanNumPoolThreads' => { 'alias' => 'PvScanPoolThrd', 'type' => 'gauge' },
    'ScanCorePoolThreads' => { 'alias' => 'PvScanPoolCore', 'type' => 'gauge' },
    'ScanPeakPoolThreads' => { 'alias' => 'PvScanPoolPeak', 'type' => 'gauge' },
    'ScanTasksTotal' => { 'alias' => 'PvScanTasksTot', 'type' => 'counter' },
    'ScanTasksCompleted' => { 'alias' => 'PvScanTasksCpt', 'type' => 'counter' },
    'ScanCollectableServiceCount' => { 'alias' => 'PvScanSvcCount', 'type' => 'gauge' },
    'ScanTaskQueuePendingCount' => { 'alias' => 'PvScanTskQPCnt', 'type' => 'gauge' },
    'ScanTaskQueueRemainingCapacity' => { 'alias' => 'PvScanTskQRCap', 'type' => 'gauge' },
    'WriteActiveThreads' => { 'alias' => 'PvWrtThrdAct', 'type' => 'gauge' },
    'WriteNumPoolThreads' => { 'alias' => 'PvWrtPoolThrd', 'type' => 'gauge' },
    'WriteCorePoolThreads' => { 'alias' => 'PvWrtPoolCore', 'type' => 'gauge' },
    'WritePeakPoolThreads' => { 'alias' => 'PvWrtPoolPeak', 'type' => 'gauge' },
    'WriteTasksTotal' => { 'alias' => 'PvWrtTasksTot', 'type' => 'counter' },
    'WriteTasksCompleted' => { 'alias' => 'PvWrtTasksCpt', 'type' => 'counter' },
    'WriteCollectableServiceCount' => { 'alias' => 'PvWrtSvcCount', 'type' => 'gauge' },
    'WriteTaskQueuePendingCount' => { 'alias' => 'PvWrtTskQPCnt', 'type' => 'gauge' },
    'WriteTaskQueueRemainingCapacity' => { 'alias' => 'PvWrtTskQRCap', 'type' => 'gauge' },
    'ScheduledActiveThreads' => { 'alias' => 'PvSchdThrdAct', 'type' => 'gauge' },
    'ScheduledNumPoolThreads' => { 'alias' => 'PvSchdPoolThrd', 'type' => 'gauge' },
    'ScheduledCorePoolThreads' => { 'alias' => 'PvSchdPoolCore', 'type' => 'gauge' },
    'ScheduledPeakPoolThreads' => { 'alias' => 'PvSchdPoolPeak', 'type' => 'gauge' },
    'ScheduledTasksTotal' => { 'alias' => 'PvSchdTasksTot', 'type' => 'counter' },
    'ScheduledTasksCompleted' => { 'alias' => 'PvSchdTasksCpt', 'type' => 'counter' },
    'ScheduledCollectableServiceCount' => { 'alias' => 'PvSchdSvcCount', 'type' => 'gauge' },
    'ScheduledTaskQueuePendingCount' => { 'alias' => 'PvSchdTskQPCnt', 'type' => 'gauge' },
    'ScheduledTaskQueueRemainingCapacity' => { 'alias' => 'PvSchdTskQRCap', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'HikariCP Pool Stats' do
  collection_name 'jsr160'
  objectname 'com.zaxxer.hikari:type=Pool (opennms)'
  attribs(
    'ActiveConnections' => { 'alias' => 'HkriActvConn', 'type' => 'gauge' },
    'IdleConnections' => { 'alias' => 'HkriIdleConn', 'type' => 'gauge' },
    'TotalConnections' => { 'alias' => 'HkriTotlConn', 'type' => 'gauge' },
    'ThreadsAwaitingConnection' => { 'alias' => 'HkriThrdWaitConn', 'type' => 'gauge' }
  )
end
opennms_jmx_mbean 'OpenNMS SnmpPoller' do
  collection_name 'jsr160'
  objectname 'OpenNMS:Name=SnmpPoller'
  attribs(
    'ActiveThreads' => { 'alias' => 'ONMSSIPCountThrdAct', 'type' => 'gauge' },
    'NumPoolThreads' => { 'alias' => 'ONMSSIPPoolThrd', 'type' => 'gauge' },
    'CorePoolThreads' => { 'alias' => 'ONMSSIPPoolCore', 'type' => 'gauge' },
    'MaxPoolThreads' => { 'alias' => 'ONMSSIPPoolMax', 'type' => 'gauge' },
    'PeakPoolThreads' => { 'alias' => 'ONMSSIPPoolPeak', 'type' => 'gauge' },
    'TasksTotal' => { 'alias' => 'ONMSSIPTasksTot', 'type' => 'counter' },
    'TasksCompleted' => { 'alias' => 'ONMSSIPTasksCpt', 'type' => 'counter' },
    'TaskQueuePendingCount' => { 'alias' => 'ONMSSIPTskQPCnt', 'type' => 'gauge' },
    'TaskQueueRemainingCapacity' => { 'alias' => 'ONMSSIPTskQRCap', 'type' => 'gauge' }
  )
end
