opennms_jdbc_collection 'default'
opennms_jdbc_query 'opennmsEventQuery' do
  collection_name 'default'
  recheck_interval 0
  if_type 'ignore'
  query_string "SELECT COUNT(eventid) as EventCount, (SELECT reltuples AS estimate FROM pg_class WHERE relname = 'events') FROM events WHERE eventtime BETWEEN (CURRENT_TIMESTAMP - INTERVAL '1 day') AND CURRENT_TIMESTAMP;"
  columns(
    'eventCount' => { 'data-source-name' => 'EventCount', 'type' => 'gauge', 'alias' => 'OnmsEventCount' },
    'eventEstimate' => { 'data-source-name' => 'estimate', 'type' => 'gauge', 'alias' => 'OnmsEventEstimate' }
  )
end
opennms_jdbc_query 'opennmsAlarmQuery' do
  collection_name 'default'
  recheck_interval 0
  if_type 'ignore'
  query_string 'SELECT COUNT(alarmid) as AlarmCount FROM alarms;'
  columns(
    'alarmCount' => { 'data-source-name' => 'AlarmCount', 'type' => 'gauge', 'alias' => 'OnmsAlarmCount' }
  )
end

opennms_jdbc_query 'opennmsNodeQuery' do
  collection_name 'default'
  recheck_interval 0
  if_type 'ignore'
  query_string "SELECT COUNT(*) as NodeCount FROM node WHERE nodetype != 'D';"
  columns(
    'nodeCount' => { 'data-source-name' => 'NodeCount', 'type' => 'gauge', 'alias' => 'OnmsNodeCount' }
  )
end

opennms_jdbc_collection 'MySQL-Global-Stats'
opennms_jdbc_query 'Q_MyUptime' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'UPTIME'"
  columns('UPTIME' => { 'data-source-name' => 'Value', 'alias' => 'MyUptime', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_MyBytesReceived' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'BYTES_RECEIVED'"
  columns('BYTES_RECEIVED' => { 'data-source-name' => 'Value', 'alias' => 'MyBytesReceived', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_MyBytesSent' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'BYTES_SENT'"
  columns('BYTES_SENT' => { 'data-source-name' => 'Value', 'alias' => 'MyBytesSent', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_delete' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_DELETE'"
  columns('COM_DELETE' => { 'data-source-name' => 'Value', 'alias' => 'MyComDelete', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_delete_multi' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_DELETE_MULTI'"
  columns('COM_DELETE_MULTI' => { 'data-source-name' => 'Value', 'alias' => 'MyComDeleteMulti', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_insert' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_INSERT'"
  columns('COM_INSERT' => { 'data-source-name' => 'Value', 'alias' => 'MyComInsert', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_insert_select' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_INSERT_SELECT'"
  columns('COM_INSERT_SELECT' => { 'data-source-name' => 'Value', 'alias' => 'MyComInsertSelect', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_select' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_SELECT'"
  columns('COM_SELECT' => { 'data-source-name' => 'Value', 'alias' => 'MyComSelect', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_stmt_execute' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_STMT_EXECUTE'"
  columns('COM_STMT_EXECUTE' => { 'data-source-name' => 'Value', 'alias' => 'MyComStmtExecute', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_update' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_UPDATE'"
  columns('COM_UPDATE' => { 'data-source-name' => 'Value', 'alias' => 'MyComUpdate', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Com_update_multi' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'COM_UPDATE_MULTI'"
  columns('COM_UPDATE_MULTI' => { 'data-source-name' => 'Value', 'alias' => 'MyComUpdateMulti', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Created_tmp_disk_tables' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'CREATED_TMP_DISK_TABLES'"
  columns('CREATED_TMP_DISK_TABLES' => { 'data-source-name' => 'Value', 'alias' => 'MyCreatTmpDiskTbl', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Created_tmp_tables' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'CREATED_TMP_TABLES'"
  columns('CREATED_TMP_TABLES' => { 'data-source-name' => 'Value', 'alias' => 'MyCreatTmpTables', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_key_buffer_size' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL VARIABLES WHERE VARIABLE_NAME ='KEY_BUFFER_SIZE'"
  columns('KEY_BUFFER_SIZE' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyBufferSize', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_key_cache_block_size' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL VARIABLES WHERE VARIABLE_NAME ='KEY_CACHE_BLOCK_SIZE'"
  columns('KEY_CACHE_BLOCK_SIZE' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyCacheBlkSize', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Key_blocks_unused' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_BLOCKS_UNUSED'"
  columns('KEY_BLOCKS_UNUSED' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyBlkUnused', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Key_read_requests' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_READ_REQUESTS'"
  columns('KEY_READ_REQUESTS' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyReadReqs', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Key_reads' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_READS'"
  columns('KEY_READS' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyReads', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Key_write_requests' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_WRITE_REQUESTS'"
  columns('KEY_WRITE_REQUESTS' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyWriteReqs', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Key_writes' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'KEY_WRITES'"
  columns('KEY_WRITES' => { 'data-source-name' => 'Value', 'alias' => 'MyKeyWrites', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Open_files' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'OPEN_FILES'"
  columns('OPEN_FILES' => { 'data-source-name' => 'Value', 'alias' => 'MyOpenFiles', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Open_tables' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'OPEN_TABLES'"
  columns('OPEN_TABLES' => { 'data-source-name' => 'Value', 'alias' => 'MyOpenTables', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_table_open_cache' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL VARIABLES WHERE VARIABLE_NAME ='TABLE_OPEN_CACHE'"
  columns('TABLE_OPEN_CACHE' => { 'data-source-name' => 'Value', 'alias' => 'MyTableOpenCache', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Questions' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'QUESTIONS'"
  columns('QUESTIONS' => { 'data-source-name' => 'Value', 'alias' => 'MyQuestions', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Slow_queries' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'SLOW_QUERIES'"
  columns('SLOW_QUERIES' => { 'data-source-name' => 'Value', 'alias' => 'MySlowQueries', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Connections' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'CONNECTIONS'"
  columns('CONNECTIONS' => { 'data-source-name' => 'Value', 'alias' => 'MyConnections', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Threads_created' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_CREATED'"
  columns('THREADS_CREATED' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsCreatd', 'type' => 'counter' })
end
opennms_jdbc_query 'Q_Threads_cached' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_CACHED'"
  columns('THREADS_CACHED' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsCachd', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Threads_connected' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_CONNECTED'"
  columns('THREADS_CONNECTED' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsCnnctd', 'type' => 'gauge' })
end
opennms_jdbc_query 'Q_Threads_running' do
  collection_name 'MySQL-Global-Stats'
  recheck_interval 0
  if_type 'ignore'
  query_string "SHOW GLOBAL STATUS WHERE VARIABLE_NAME = 'THREADS_RUNNING'"
  columns('THREADS_RUNNING' => { 'data-source-name' => 'Value', 'alias' => 'MyThreadsRunng', 'type' => 'gauge' })
end
opennms_jdbc_collection 'PostgreSQL'
opennms_jdbc_query 'pg_tablespace_size' do
  collection_name 'PostgreSQL'
  recheck_interval 0
  if_type 'all'
  resource_type 'pgTableSpace'
  instance_column 'spcname'
  query_string "\n                    SELECT spcname, pg_tablespace_size(pg_tablespace.spcname) AS ts_size\n                    FROM pg_tablespace\n                    "
  columns(
           'spcname' => { 'data-source-name' => 'spcname', 'type' => 'string', 'alias' => 'spcname' },
           'ts_size' => { 'data-source-name' => 'ts_size', 'type' => 'gauge', 'alias' => 'ts_size' }
         )
end
opennms_jdbc_query 'pg_stat_database' do
  collection_name 'PostgreSQL'
  recheck_interval 0
  if_type 'all'
  resource_type 'pgDatabase'
  instance_column 'datname'
  query_string "\n                    SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit,\n                           pg_database_size(pg_stat_database.datname) AS db_size\n                    FROM pg_stat_database\n                    WHERE datname NOT IN ('template0', 'template1')\n                    "
  columns(
    'datname' => { 'data-source-name' => 'datname', 'type' => 'string', 'alias' => 'datname' },
    'numbackends' => { 'data-source-name' => 'numbackends', 'type' => 'gauge', 'alias' => 'numbackends' },
    'xact_commit' => { 'data-source-name' => 'xact_commit', 'type' => 'counter', 'alias' => 'xact_commit' },
    'xact_rollback' => { 'data-source-name' => 'xact_rollback', 'type' => 'counter', 'alias' => 'xact_rollback' },
    'blks_read' => { 'data-source-name' => 'blks_read', 'type' => 'counter', 'alias' => 'blks_read' },
    'blks_hit' => { 'data-source-name' => 'blks_hit', 'type' => 'counter', 'alias' => 'blks_hit' },
    'db_size' => { 'data-source-name' => 'db_size', 'type' => 'gauge', 'alias' => 'db_size' }
  )
end
