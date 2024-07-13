/*
Performance test setup.

WARNING: DO NOT RUN THIS IN PRODUCTION!

1. create database.
a. local database with defaults. Large enough that the file doesn't have to grow. 1 GB should suffice.
b. Azure database, every SKU possible. From S0 to business critical. To keep costs under control, for the non-serverless versions use 4, 8, 16 and 32 core DB's

2. Run the scripts below with SqlStress or SSMS. Every script has a pointer where to run it. 
    The scripts you need to run with SQLStress: for the local machine on the local machine. 
        For the Azure DB on a 4 Core 16 GB Windows VM in the same subnet as the database with private endpoints enabled.
    It's up to you to choose between a B or D series VM. If you choose a B-series, make sure to run the workload more than once to get comparable results.
    Don't forget to empty the cache before you start! This means, DO NOT RUN THIS IN PRODUCTION!
Check the connection to make sure you're using the local subnet and not the internet route. 

3. Check the wait statistics to see where bottlenecks may occur
4. Check the IO stats to see where bottlenecks may occur
5. Check the portal for information
6. Check the Query Store for information
7. Log the data for future reference
8. DO NOT RUN THIS IN PRODUCTION


This script contains everything you need to do a stupid load test. Adapt it to whatever you see fit in your situation.
Maybe 10 tables to test join performance? Or 250 columns to test wide tables?
The datatypes are all over the place, this is by design to create a messy table. 

REMINDER: DO NOT RUN THIS IN PRODUCTION
*/

/* system description */

SELECT physical_memory_kb/1024/1024 AS [GB memory available],
committed_target_kb/1024/1024 AS [GB sql memory],
cpu_count AS [cpu cores],
socket_count,
numa_node_count,
cores_per_socket
max_workers_count,
scheduler_count,
scheduler_total_count,
virtual_machine_type_desc,
@@VERSION AS [sql server version]
FROM sys.dm_os_sys_info

/* Check the resource governance settings */
select *
from sys.dm_user_db_resource_governance

/* Check the workers */
select * from sys.dm_os_workers

/* Check the schedulers */
select * from sys.dm_os_schedulers

/* Check any running requests */
select *
from sys.dm_exec_requests
SELECT * FROM sys.sysprocesses

/* Check your connection (you want a local IP, no internet based IP) */
SELECT client_net_address, local_net_address 
FROM sys.dm_exec_connections

/* Create the testing table */

SET NOCOUNT ON

DROP TABLE IF EXISTS dbo.PerfTest;

CREATE TABLE dbo.PerfTest (
ID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
val1 INT NULL,
val2 VARCHAR(100) NULL,
val3 NVARCHAR(100) NULL,
val4 CHAR(50) NULL,
val5 NCHAR(50) NULL,
val6 DECIMAL(38,15) NULL,
val7 REAL NULL,
val8 MONEY NULL,
val9 BIGINT NULL,
val10 VARCHAR(MAX) NULL,
val11 NVARCHAR(MAX) NULL,
val12 CHAR(50) NULL,
val13 NCHAR(50) NULL,
val14 DECIMAL(38,15) NULL,
val15 REAL NULL,
val16 MONEY NULL
);

/* Add ridiculous indexes, just because we can */

CREATE NONCLUSTERED INDEX ncix_report1 ON dbo.PerfTest
(val1,val2,val3,val4)
INCLUDE
(val5, val6, val7, val8);

CREATE NONCLUSTERED INDEX ncix_report2 ON dbo.PerfTest
(val16, val15, val14, val13)
INCLUDE
(val12, val11, val10, val9);


/* Wait Stats Monitoring start */
/* Run this script only once, just before your start the insert data test! */
CREATE TABLE ws_Capture
(
    wst_WaitType        VARCHAR(150),
    wst_WaitTime        BIGINT,
    wst_WaitingTasks    BIGINT,
    wst_SignalWaitTime  BIGINT
)

INSERT INTO ws_Capture
    SELECT
        wait_type, 
        wait_time_ms,
        waiting_tasks_count,
        signal_wait_time_ms
    FROM sys.dm_os_wait_stats


/* File latency monitoring start */
CREATE TABLE FileLatency
(
CaptureDateTime DATETIME,
[ReadLatency] BIGINT,
[WriteLatency] BIGINT,
[Latency] BIGINT,
[AvgBPerRead] BIGINT,
[AvgBPerWrite] BIGINT,
[AvgBPerTransfer] BIGINT,
[Drive] VARCHAR(10),
[DB] VARCHAR(150),
[sample_ms] BIGINT,
[num_of_reads] BIGINT,
[num_of_bytes_read] BIGINT,
[io_stall_read_ms] BIGINT,
[num_of_writes] BIGINT,
[num_of_bytes_written] BIGINT,
[io_stall_write_ms] BIGINT,
[io_stall] BIGINT,
[size_on_disk_MB]DECIMAL(12,6),
[physical_name] VARCHAR(250)
)

INSERT INTO FileLatency
(
    CaptureDateTime,
    ReadLatency,
    WriteLatency,
    Latency,
    AvgBPerRead,
    AvgBPerWrite,
    AvgBPerTransfer,
    Drive,
    DB,
    sample_ms,
    num_of_reads,
    num_of_bytes_read,
    io_stall_read_ms,
    num_of_writes,
    num_of_bytes_written,
    io_stall_write_ms,
    io_stall,
    size_on_disk_MB,
    physical_name
)

SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END [ReadLatency],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END [WriteLatency],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END [Latency],
    --avg bytes per IOP
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END [AvgBPerRead],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END [AvgBPerWrite],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
    JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
ORDER BY [Latency] DESC;




/* Insert data test */
/* 20000 iterations, 50 threads  25 on Basic to prevent monitoring threads to get killed*/

INSERT INTO dbo.PerfTest
(val1, val2,val3,val4,val5,val6,val7,val8,val9,val10,val11,val12,val13,val14,val15,val16)
SELECT RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND(), RAND();





/* Check the wait stats! */

    SELECT
        GETDATE() AS [DATETIME],
        dm.wait_type AS WaitType,
        dm.wait_time_ms - ws.wst_WaitTime AS WaitTime,
        dm.waiting_tasks_count - ws.wst_WaitingTasks AS WaitingTasks,
        dm.signal_wait_time_ms - ws.wst_SignalWaitTime AS SignalWaitTime
    FROM sys.dm_os_wait_stats dm
        INNER JOIN ws_Capture ws ON dm.wait_type = ws.wst_WaitType
where  dm.wait_type NOT IN (
N'BROKER_EVENTHANDLER' ,N'BROKER_RECEIVE_WAITFOR',N'BROKER_TASK_STOP',N'BROKER_TO_FLUSH',N'BROKER_TRANSMITTER',N'CHECKPOINT_QUEUE',N'CHKPT',N'CLR_AUTO_EVENT',N'CLR_MANUAL_EVENT',N'CLR_SEMAPHORE'
,-- Maybe uncomment these four if you have mirroring issues
N'DBMIRROR_DBM_EVENT',N'DBMIRROR_EVENTS_QUEUE',N'DBMIRROR_WORKER_QUEUE',N'DBMIRRORING_CMD',N'DIRTY_PAGE_POLL',N'DISPATCHER_QUEUE_SEMAPHORE',N'EXECSYNC',N'FSAGENT',N'FT_IFTS_SCHEDULER_IDLE_WAIT',N'FT_IFTSHC_MUTEX',
-- Maybe uncomment these six if you have AG issues
N'HADR_CLUSAPI_CALL',N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'HADR_LOGCAPTURE_WAIT',N'HADR_NOTIFICATION_DEQUEUE' ,N'HADR_TIMER_TASK',N'HADR_WORK_QUEUE',N'KSOURCE_WAKEUP',N'LAZYWRITER_SLEEP',N'LOGMGR_QUEUE',N'MEMORY_ALLOCATION_EXT',N'ONDEMAND_TASK_QUEUE',N'PREEMPTIVE_XE_GETTARGETSTATE',N'PWAIT_ALL_COMPONENTS_INITIALIZED',N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'
,N'QDS_ASYNC_QUEUE',N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_SHUTDOWN_QUEUE',N'REDO_THREAD_PENDING_WORK',N'REQUEST_FOR_DEADLOCK_SEARCH',N'RESOURCE_QUEUE',N'SERVER_IDLE_CHECK',N'SLEEP_BPOOL_FLUSH',N'SLEEP_DBSTARTUP',N'SLEEP_DCOMSTARTUP',N'SLEEP_MASTERDBREADY',N'SLEEP_MASTERMDREADY',N'SLEEP_MASTERUPGRADED',N'SLEEP_MSDBSTARTUP',N'SLEEP_SYSTEMTASK',N'SLEEP_TASK',N'SLEEP_TEMPDBSTARTUP'
,N'SNI_HTTP_ACCEPT',N'SP_SERVER_DIAGNOSTICS_SLEEP',N'SQLTRACE_BUFFER_FLUSH',N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',N'SQLTRACE_WAIT_ENTRIES',N'WAIT_FOR_RESULTS',N'WAITFOR',N'WAITFOR_TASKSHUTDOWN',N'WAIT_XTP_RECOVERY',N'WAIT_XTP_HOST_WAIT',N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',N'WAIT_XTP_CKPT_CLOSE',N'XE_DISPATCHER_JOIN',N'XE_DISPATCHER_WAIT',N'XE_TIMER_EVENT', N'SOS_WORK_DISPATCHER')
and dm.wait_time_ms - ws.wst_WaitTime > 0
order by WaitTime DESC;

DROP TABLE ws_Capture; 


/* Check the disk latency */
SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
F.CaptureDateTime as PrevCaptureDateTime,
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[io_stall_read_ms] / vfs.[num_of_reads]) END - F.ReadLatency [ReadLatency],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[io_stall_write_ms] / vfs.[num_of_writes]) END - F.WriteLatency [WriteLatency],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE (vfs.[io_stall] / (vfs.[num_of_reads] + vfs.[num_of_writes])) END - F.Latency [Latency],
    --avg bytes per IOP
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[num_of_bytes_read] / vfs.[num_of_reads]) END  [AvgBPerRead],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[num_of_bytes_written] / vfs.[num_of_writes]) END [AvgBPerWrite],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE ((vfs.[num_of_bytes_read] + vfs.[num_of_bytes_written]) / (vfs.[num_of_reads] + vfs.[num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
        JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
JOIN FileLatency F on DB_NAME([vfs].[database_id]) = F.DB
ORDER BY [Latency] DESC;

DROP TABLE FileLatency

/*
Next step
*/

/* Wait Stats Monitoring start */
/* Run this script only once, just before your start the insert data test! */
CREATE TABLE ws_Capture
(
    wst_WaitType        VARCHAR(150),
    wst_WaitTime        BIGINT,
    wst_WaitingTasks    BIGINT,
    wst_SignalWaitTime  BIGINT
)

INSERT INTO ws_Capture
    SELECT
        wait_type, 
        wait_time_ms,
        waiting_tasks_count,
        signal_wait_time_ms
    FROM sys.dm_os_wait_stats


/* File latency monitoring start */
CREATE TABLE FileLatency
(
CaptureDateTime DATETIME,
[ReadLatency] BIGINT,
[WriteLatency] BIGINT,
[Latency] BIGINT,
[AvgBPerRead] BIGINT,
[AvgBPerWrite] BIGINT,
[AvgBPerTransfer] BIGINT,
[Drive] VARCHAR(10),
[DB] VARCHAR(150),
[sample_ms] BIGINT,
[num_of_reads] BIGINT,
[num_of_bytes_read] BIGINT,
[io_stall_read_ms] BIGINT,
[num_of_writes] BIGINT,
[num_of_bytes_written] BIGINT,
[io_stall_write_ms] BIGINT,
[io_stall] BIGINT,
[size_on_disk_MB]DECIMAL(12,6),
[physical_name] VARCHAR(250)
)

INSERT INTO FileLatency
(
    CaptureDateTime,
    ReadLatency,
    WriteLatency,
    Latency,
    AvgBPerRead,
    AvgBPerWrite,
    AvgBPerTransfer,
    Drive,
    DB,
    sample_ms,
    num_of_reads,
    num_of_bytes_read,
    io_stall_read_ms,
    num_of_writes,
    num_of_bytes_written,
    io_stall_write_ms,
    io_stall,
    size_on_disk_MB,
    physical_name
)

SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END [ReadLatency],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END [WriteLatency],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END [Latency],
    --avg bytes per IOP
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END [AvgBPerRead],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END [AvgBPerWrite],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
        JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
ORDER BY [Latency] DESC;



/* select data test */
/* 2000 iterations, 15 threads */

set statistics time, io on

DECLARE @sec INT = (SELECT DATEPART(SECOND,SYSDATETIME()))

IF(@sec BETWEEN 0 AND 5)
SELECT top 100 val3, val5, val7 FROM dbo.PerfTest
ORDER BY val1

IF(@sec BETWEEN 6 AND 11)
SELECT top 100 val6, val8, val10 FROM dbo.PerfTest
ORDER BY val3

IF(@sec BETWEEN 12 AND 18)
SELECT top 100 val4, val6, val8 FROM dbo.PerfTest
ORDER BY val6

IF(@sec BETWEEN 19 AND 28)
SELECT top 100 val9, val11, val13 FROM dbo.PerfTest
ORDER BY val4

IF(@sec BETWEEN 29 AND 38)
SELECT top 100 val7, val9, val11 FROM dbo.PerfTest
ORDER BY val9

IF(@sec BETWEEN 29 AND 48)
SELECT top 100 val10, val12, val14 FROM dbo.PerfTest
ORDER BY val7

IF(@sec BETWEEN 49 AND 58)
SELECT top 100 val12, val14, val16 FROM dbo.PerfTest
ORDER BY val10

ELSE
SELECT top 100 val1,val3,val5 FROM dbo.PerfTest
ORDER BY val12


/* Check the wait stats! */

    SELECT
        GETDATE() AS [DATETIME],
        dm.wait_type AS WaitType,
        dm.wait_time_ms - ws.wst_WaitTime AS WaitTime,
        dm.waiting_tasks_count - ws.wst_WaitingTasks AS WaitingTasks,
        dm.signal_wait_time_ms - ws.wst_SignalWaitTime AS SignalWaitTime
    FROM sys.dm_os_wait_stats dm
        INNER JOIN ws_Capture ws ON dm.wait_type = ws.wst_WaitType
where  dm.wait_type NOT IN (
N'BROKER_EVENTHANDLER' ,N'BROKER_RECEIVE_WAITFOR',N'BROKER_TASK_STOP',N'BROKER_TO_FLUSH',N'BROKER_TRANSMITTER',N'CHECKPOINT_QUEUE',N'CHKPT',N'CLR_AUTO_EVENT',N'CLR_MANUAL_EVENT',N'CLR_SEMAPHORE'
,-- Maybe uncomment these four if you have mirroring issues
N'DBMIRROR_DBM_EVENT',N'DBMIRROR_EVENTS_QUEUE',N'DBMIRROR_WORKER_QUEUE',N'DBMIRRORING_CMD',N'DIRTY_PAGE_POLL',N'DISPATCHER_QUEUE_SEMAPHORE',N'EXECSYNC',N'FSAGENT',N'FT_IFTS_SCHEDULER_IDLE_WAIT',N'FT_IFTSHC_MUTEX',
-- Maybe uncomment these six if you have AG issues
N'HADR_CLUSAPI_CALL',N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'HADR_LOGCAPTURE_WAIT',N'HADR_NOTIFICATION_DEQUEUE' ,N'HADR_TIMER_TASK',N'HADR_WORK_QUEUE',N'KSOURCE_WAKEUP',N'LAZYWRITER_SLEEP',N'LOGMGR_QUEUE',N'MEMORY_ALLOCATION_EXT',N'ONDEMAND_TASK_QUEUE',N'PREEMPTIVE_XE_GETTARGETSTATE',N'PWAIT_ALL_COMPONENTS_INITIALIZED',N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'
,N'QDS_ASYNC_QUEUE',N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_SHUTDOWN_QUEUE',N'REDO_THREAD_PENDING_WORK',N'REQUEST_FOR_DEADLOCK_SEARCH',N'RESOURCE_QUEUE',N'SERVER_IDLE_CHECK',N'SLEEP_BPOOL_FLUSH',N'SLEEP_DBSTARTUP',N'SLEEP_DCOMSTARTUP',N'SLEEP_MASTERDBREADY',N'SLEEP_MASTERMDREADY',N'SLEEP_MASTERUPGRADED',N'SLEEP_MSDBSTARTUP',N'SLEEP_SYSTEMTASK',N'SLEEP_TASK',N'SLEEP_TEMPDBSTARTUP'
,N'SNI_HTTP_ACCEPT',N'SP_SERVER_DIAGNOSTICS_SLEEP',N'SQLTRACE_BUFFER_FLUSH',N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',N'SQLTRACE_WAIT_ENTRIES',N'WAIT_FOR_RESULTS',N'WAITFOR',N'WAITFOR_TASKSHUTDOWN',N'WAIT_XTP_RECOVERY',N'WAIT_XTP_HOST_WAIT',N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',N'WAIT_XTP_CKPT_CLOSE',N'XE_DISPATCHER_JOIN',N'XE_DISPATCHER_WAIT',N'XE_TIMER_EVENT', N'SOS_WORK_DISPATCHER')
and dm.wait_time_ms - ws.wst_WaitTime > 0
order by WaitTime DESC;

DROP TABLE ws_Capture; 


/* Check the disk latency */
SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
F.CaptureDateTime as PrevCaptureDateTime,
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[io_stall_read_ms] / vfs.[num_of_reads]) END - F.ReadLatency [ReadLatency],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[io_stall_write_ms] / vfs.[num_of_writes]) END - F.WriteLatency [WriteLatency],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE (vfs.[io_stall] / (vfs.[num_of_reads] + vfs.[num_of_writes])) END - F.Latency [Latency],
    --avg bytes per IOP
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[num_of_bytes_read] / vfs.[num_of_reads]) END  [AvgBPerRead],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[num_of_bytes_written] / vfs.[num_of_writes]) END [AvgBPerWrite],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE ((vfs.[num_of_bytes_read] + vfs.[num_of_bytes_written]) / (vfs.[num_of_reads] + vfs.[num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
JOIN FileLatency F on DB_NAME([vfs].[database_id]) = F.DB
ORDER BY [Latency] DESC;

DROP TABLE FileLatency

/* next step */

/* Wait Stats Monitoring start */
/* Run this script only once, just before your start the delete data test! */
CREATE TABLE ws_Capture
(
    wst_WaitType        VARCHAR(150),
    wst_WaitTime        BIGINT,
    wst_WaitingTasks    BIGINT,
    wst_SignalWaitTime  BIGINT
)

INSERT INTO ws_Capture
    SELECT
        wait_type, 
        wait_time_ms,
        waiting_tasks_count,
        signal_wait_time_ms
    FROM sys.dm_os_wait_stats


/* File latency monitoring start */
CREATE TABLE FileLatency
(
CaptureDateTime DATETIME,
[ReadLatency] BIGINT,
[WriteLatency] BIGINT,
[Latency] BIGINT,
[AvgBPerRead] BIGINT,
[AvgBPerWrite] BIGINT,
[AvgBPerTransfer] BIGINT,
[Drive] VARCHAR(10),
[DB] VARCHAR(150),
[sample_ms] BIGINT,
[num_of_reads] BIGINT,
[num_of_bytes_read] BIGINT,
[io_stall_read_ms] BIGINT,
[num_of_writes] BIGINT,
[num_of_bytes_written] BIGINT,
[io_stall_write_ms] BIGINT,
[io_stall] BIGINT,
[size_on_disk_MB]DECIMAL(12,6),
[physical_name] VARCHAR(250)
)


INSERT INTO FileLatency
(
    CaptureDateTime,
    ReadLatency,
    WriteLatency,
    Latency,
    AvgBPerRead,
    AvgBPerWrite,
    AvgBPerTransfer,
    Drive,
    DB,
    sample_ms,
    num_of_reads,
    num_of_bytes_read,
    io_stall_read_ms,
    num_of_writes,
    num_of_bytes_written,
    io_stall_write_ms,
    io_stall,
    size_on_disk_MB,
    physical_name
)

SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END [ReadLatency],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END [WriteLatency],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END [Latency],
    --avg bytes per IOP
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END [AvgBPerRead],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END [AvgBPerWrite],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
        JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
ORDER BY [Latency] DESC;




/* Delete test */
/* 2000 iterations, 150 threads */

DECLARE @delid int = (SELECT ABS(CHECKSUM(NEWID()) % 20000))

DELETE from dbo.PerfTest where Id = @delid

/* Check the wait stats! */

    SELECT
        GETDATE() AS [DATETIME],
        dm.wait_type AS WaitType,
        dm.wait_time_ms - ws.wst_WaitTime AS WaitTime,
        dm.waiting_tasks_count - ws.wst_WaitingTasks AS WaitingTasks,
        dm.signal_wait_time_ms - ws.wst_SignalWaitTime AS SignalWaitTime
    FROM sys.dm_os_wait_stats dm
        INNER JOIN ws_Capture ws ON dm.wait_type = ws.wst_WaitType
where  dm.wait_type NOT IN (
N'BROKER_EVENTHANDLER' ,N'BROKER_RECEIVE_WAITFOR',N'BROKER_TASK_STOP',N'BROKER_TO_FLUSH',N'BROKER_TRANSMITTER',N'CHECKPOINT_QUEUE',N'CHKPT',N'CLR_AUTO_EVENT',N'CLR_MANUAL_EVENT',N'CLR_SEMAPHORE'
,-- Maybe uncomment these four if you have mirroring issues
N'DBMIRROR_DBM_EVENT',N'DBMIRROR_EVENTS_QUEUE',N'DBMIRROR_WORKER_QUEUE',N'DBMIRRORING_CMD',N'DIRTY_PAGE_POLL',N'DISPATCHER_QUEUE_SEMAPHORE',N'EXECSYNC',N'FSAGENT',N'FT_IFTS_SCHEDULER_IDLE_WAIT',N'FT_IFTSHC_MUTEX',
-- Maybe uncomment these six if you have AG issues
N'HADR_CLUSAPI_CALL',N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'HADR_LOGCAPTURE_WAIT',N'HADR_NOTIFICATION_DEQUEUE' ,N'HADR_TIMER_TASK',N'HADR_WORK_QUEUE',N'KSOURCE_WAKEUP',N'LAZYWRITER_SLEEP',N'LOGMGR_QUEUE',N'MEMORY_ALLOCATION_EXT',N'ONDEMAND_TASK_QUEUE',N'PREEMPTIVE_XE_GETTARGETSTATE',N'PWAIT_ALL_COMPONENTS_INITIALIZED',N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'
,N'QDS_ASYNC_QUEUE',N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_SHUTDOWN_QUEUE',N'REDO_THREAD_PENDING_WORK',N'REQUEST_FOR_DEADLOCK_SEARCH',N'RESOURCE_QUEUE',N'SERVER_IDLE_CHECK',N'SLEEP_BPOOL_FLUSH',N'SLEEP_DBSTARTUP',N'SLEEP_DCOMSTARTUP',N'SLEEP_MASTERDBREADY',N'SLEEP_MASTERMDREADY',N'SLEEP_MASTERUPGRADED',N'SLEEP_MSDBSTARTUP',N'SLEEP_SYSTEMTASK',N'SLEEP_TASK',N'SLEEP_TEMPDBSTARTUP'
,N'SNI_HTTP_ACCEPT',N'SP_SERVER_DIAGNOSTICS_SLEEP',N'SQLTRACE_BUFFER_FLUSH',N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',N'SQLTRACE_WAIT_ENTRIES',N'WAIT_FOR_RESULTS',N'WAITFOR',N'WAITFOR_TASKSHUTDOWN',N'WAIT_XTP_RECOVERY',N'WAIT_XTP_HOST_WAIT',N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',N'WAIT_XTP_CKPT_CLOSE',N'XE_DISPATCHER_JOIN',N'XE_DISPATCHER_WAIT',N'XE_TIMER_EVENT', N'SOS_WORK_DISPATCHER')
and dm.wait_time_ms - ws.wst_WaitTime > 0
order by WaitTime DESC;

DROP TABLE ws_Capture; 


/* Check the disk latency */
SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
F.CaptureDateTime as PrevCaptureDateTime,
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[io_stall_read_ms] / vfs.[num_of_reads]) END - F.ReadLatency [ReadLatency],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[io_stall_write_ms] / vfs.[num_of_writes]) END - F.WriteLatency [WriteLatency],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE (vfs.[io_stall] / (vfs.[num_of_reads] + vfs.[num_of_writes])) END - F.Latency [Latency],
    --avg bytes per IOP
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[num_of_bytes_read] / vfs.[num_of_reads]) END  [AvgBPerRead],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[num_of_bytes_written] / vfs.[num_of_writes]) END [AvgBPerWrite],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE ((vfs.[num_of_bytes_read] + vfs.[num_of_bytes_written]) / (vfs.[num_of_reads] + vfs.[num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
JOIN FileLatency F on DB_NAME([vfs].[database_id]) = F.DB
ORDER BY [Latency] DESC;

DROP TABLE FileLatency

/* Final step */

/* Wait Stats Monitoring start */
/* Run this script only once, just before your start the delete data test! */
CREATE TABLE ws_Capture
(
    wst_WaitType        VARCHAR(150),
    wst_WaitTime        BIGINT,
    wst_WaitingTasks    BIGINT,
    wst_SignalWaitTime  BIGINT
)

INSERT INTO ws_Capture
    SELECT
        wait_type, 
        wait_time_ms,
        waiting_tasks_count,
        signal_wait_time_ms
    FROM sys.dm_os_wait_stats


/* File latency monitoring start */
CREATE TABLE FileLatency
(
CaptureDateTime DATETIME,
[ReadLatency] BIGINT,
[WriteLatency] BIGINT,
[Latency] BIGINT,
[AvgBPerRead] BIGINT,
[AvgBPerWrite] BIGINT,
[AvgBPerTransfer] BIGINT,
[Drive] VARCHAR(10),
[DB] VARCHAR(150),
[sample_ms] BIGINT,
[num_of_reads] BIGINT,
[num_of_bytes_read] BIGINT,
[io_stall_read_ms] BIGINT,
[num_of_writes] BIGINT,
[num_of_bytes_written] BIGINT,
[io_stall_write_ms] BIGINT,
[io_stall] BIGINT,
[size_on_disk_MB]DECIMAL(12,6),
[physical_name] VARCHAR(250)
)

INSERT INTO FileLatency
(
    CaptureDateTime,
    ReadLatency,
    WriteLatency,
    Latency,
    AvgBPerRead,
    AvgBPerWrite,
    AvgBPerTransfer,
    Drive,
    DB,
    sample_ms,
    num_of_reads,
    num_of_bytes_read,
    io_stall_read_ms,
    num_of_writes,
    num_of_bytes_written,
    io_stall_write_ms,
    io_stall,
    size_on_disk_MB,
    physical_name
)

SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END [ReadLatency],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END [WriteLatency],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END [Latency],
    --avg bytes per IOP
    CASE WHEN [num_of_reads] = 0 THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END [AvgBPerRead],
    CASE WHEN [io_stall_write_ms] = 0 THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END [AvgBPerWrite],
    CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
        JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
ORDER BY [Latency] DESC;




/* Update test */
/* 2000 iterations, 150 threads */

DECLARE @upid int = (SELECT ABS(CHECKSUM(NEWID()) % 20000))

UPDATE  dbo.PerfTest 
set val2 = CONCAT(val2, ' ', val3), 
val6 = val6 * 12,
val9 = val9 / 1245,
val16 = val16 + 34234324
where Id = @upid

/* Check the wait stats! */

    SELECT
        GETDATE() AS [DATETIME],
        dm.wait_type AS WaitType,
        dm.wait_time_ms - ws.wst_WaitTime AS WaitTime,
        dm.waiting_tasks_count - ws.wst_WaitingTasks AS WaitingTasks,
        dm.signal_wait_time_ms - ws.wst_SignalWaitTime AS SignalWaitTime
    FROM sys.dm_os_wait_stats dm
        INNER JOIN ws_Capture ws ON dm.wait_type = ws.wst_WaitType
where  dm.wait_type NOT IN (
N'BROKER_EVENTHANDLER' ,N'BROKER_RECEIVE_WAITFOR',N'BROKER_TASK_STOP',N'BROKER_TO_FLUSH',N'BROKER_TRANSMITTER',N'CHECKPOINT_QUEUE',N'CHKPT',N'CLR_AUTO_EVENT',N'CLR_MANUAL_EVENT',N'CLR_SEMAPHORE'
,-- Maybe uncomment these four if you have mirroring issues
N'DBMIRROR_DBM_EVENT',N'DBMIRROR_EVENTS_QUEUE',N'DBMIRROR_WORKER_QUEUE',N'DBMIRRORING_CMD',N'DIRTY_PAGE_POLL',N'DISPATCHER_QUEUE_SEMAPHORE',N'EXECSYNC',N'FSAGENT',N'FT_IFTS_SCHEDULER_IDLE_WAIT',N'FT_IFTSHC_MUTEX',
-- Maybe uncomment these six if you have AG issues
N'HADR_CLUSAPI_CALL',N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'HADR_LOGCAPTURE_WAIT',N'HADR_NOTIFICATION_DEQUEUE' ,N'HADR_TIMER_TASK',N'HADR_WORK_QUEUE',N'KSOURCE_WAKEUP',N'LAZYWRITER_SLEEP',N'LOGMGR_QUEUE',N'MEMORY_ALLOCATION_EXT',N'ONDEMAND_TASK_QUEUE',N'PREEMPTIVE_XE_GETTARGETSTATE',N'PWAIT_ALL_COMPONENTS_INITIALIZED',N'PWAIT_DIRECTLOGCONSUMER_GETNEXT',N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'
,N'QDS_ASYNC_QUEUE',N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',N'QDS_SHUTDOWN_QUEUE',N'REDO_THREAD_PENDING_WORK',N'REQUEST_FOR_DEADLOCK_SEARCH',N'RESOURCE_QUEUE',N'SERVER_IDLE_CHECK',N'SLEEP_BPOOL_FLUSH',N'SLEEP_DBSTARTUP',N'SLEEP_DCOMSTARTUP',N'SLEEP_MASTERDBREADY',N'SLEEP_MASTERMDREADY',N'SLEEP_MASTERUPGRADED',N'SLEEP_MSDBSTARTUP',N'SLEEP_SYSTEMTASK',N'SLEEP_TASK',N'SLEEP_TEMPDBSTARTUP'
,N'SNI_HTTP_ACCEPT',N'SP_SERVER_DIAGNOSTICS_SLEEP',N'SQLTRACE_BUFFER_FLUSH',N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',N'SQLTRACE_WAIT_ENTRIES',N'WAIT_FOR_RESULTS',N'WAITFOR',N'WAITFOR_TASKSHUTDOWN',N'WAIT_XTP_RECOVERY',N'WAIT_XTP_HOST_WAIT',N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',N'WAIT_XTP_CKPT_CLOSE',N'XE_DISPATCHER_JOIN',N'XE_DISPATCHER_WAIT',N'XE_TIMER_EVENT', N'SOS_WORK_DISPATCHER')
and dm.wait_time_ms - ws.wst_WaitTime > 0
order by WaitTime DESC;

DROP TABLE ws_Capture; 


/* Check the disk latency */
SELECT
    --virtual file latency
    GETDATE() AS CaptureDateTime,
F.CaptureDateTime as PrevCaptureDateTime,
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[io_stall_read_ms] / vfs.[num_of_reads]) END - F.ReadLatency [ReadLatency],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[io_stall_write_ms] / vfs.[num_of_writes]) END - F.WriteLatency [WriteLatency],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE (vfs.[io_stall] / (vfs.[num_of_reads] + vfs.[num_of_writes])) END - F.Latency [Latency],
    --avg bytes per IOP
    CASE WHEN vfs.[num_of_reads] = 0 THEN 0 ELSE (vfs.[num_of_bytes_read] / vfs.[num_of_reads]) END  [AvgBPerRead],
    CASE WHEN vfs.[io_stall_write_ms] = 0 THEN 0 ELSE (vfs.[num_of_bytes_written] / vfs.[num_of_writes]) END [AvgBPerWrite],
    CASE WHEN (vfs.[num_of_reads] = 0 AND vfs.[num_of_writes] = 0) THEN 0 ELSE ((vfs.[num_of_bytes_read] + vfs.[num_of_bytes_written]) / (vfs.[num_of_reads] + vfs.[num_of_writes])) END [AvgBPerTransfer],
    LEFT([mf].[physical_name], 2) [Drive],
    DB_NAME([vfs].[database_id]) [DB],
    [vfs].[sample_ms],
    [vfs].[num_of_reads],
    [vfs].[num_of_bytes_read],
    [vfs].[io_stall_read_ms],
    [vfs].[num_of_writes],
    [vfs].[num_of_bytes_written],
    [vfs].[io_stall_write_ms],
    [vfs].[io_stall],
    [vfs].[size_on_disk_bytes] / 1024 / 1024. [size_on_disk_MB],
    [mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL, NULL) AS vfs
JOIN [sys].database_files [mf]
        ON [vfs].[database_id] = DB_ID()
           AND [vfs].[file_id] = [mf].file_id
JOIN FileLatency F on DB_NAME([vfs].[database_id]) = F.DB
ORDER BY [Latency] DESC;

DROP TABLE FileLatency
