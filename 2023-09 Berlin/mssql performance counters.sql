SELECT concat(substring(object_name,0,7),'Azure', substring(object_name,charindex(':',object_name,0),50)) as object_name,counter_name,instance_name,cntr_value
FROM sys.dm_os_performance_counters
UNION
SELECT '{$MSSQL.INSTANCE}' as object_name,'Version' as counter_name,@@version as instance_name,0 as cntr_value
UNION
SELECT '{$MSSQL.INSTANCE}' as object_name,'Uptime' as counter_name,'' as instance_name,DATEDIFF(second,sqlserver_start_time,GETDATE()) as cntr_value
FROM sys.dm_os_sys_info
UNION
SELECT '{$MSSQL.INSTANCE}:Databases' as object_name,'State' as counter_name,name as instance_name,state as cntr_value
FROM sys.databases
UNION
SELECT a.object_name,'BufferCacheHitRatio' as counter_name,'' as instance_name,cast(a.cntr_value*100.0/b.cntr_value as dec(3,0)) as cntr_value
FROM sys.dm_os_performance_counters a
JOIN (SELECT cntr_value,OBJECT_NAME
FROM sys.dm_os_performance_counters
WHERE counter_name='Buffer cache hit ratio base' AND OBJECT_NAME='{$MSSQL.INSTANCE}:Buffer Manager') b
ON a.OBJECT_NAME=b.OBJECT_NAME
WHERE a.counter_name='Buffer cache hit ratio' AND a.OBJECT_NAME='{$MSSQL.INSTANCE}:Buffer Manager'
UNION
SELECT a.object_name,'WorktablesFromCacheRatio' as counter_name,'' as instance_name,cast(a.cntr_value*100.0/b.cntr_value as dec(3,0)) as cntr_value
FROM sys.dm_os_performance_counters a
JOIN (SELECT cntr_value,OBJECT_NAME
FROM sys.dm_os_performance_counters
WHERE counter_name='Worktables From Cache Base' AND OBJECT_NAME='{$MSSQL.INSTANCE}:Access Methods') b
ON a.OBJECT_NAME=b.OBJECT_NAME
WHERE a.counter_name='Worktables From Cache Ratio' AND a.OBJECT_NAME='{$MSSQL.INSTANCE}:Access Methods'
UNION
SELECT a.object_name,'CacheHitRatio' as counter_name,'_Total' as instance_name,cast(a.cntr_value*100.0/b.cntr_value as dec(3,0)) as cntr_value
FROM sys.dm_os_performance_counters a
JOIN (SELECT cntr_value,OBJECT_NAME
FROM sys.dm_os_performance_counters
WHERE counter_name='Cache Hit Ratio base' AND OBJECT_NAME='{$MSSQL.INSTANCE}:Plan Cache' AND instance_name='_Total') b
ON a.OBJECT_NAME=b.OBJECT_NAME
WHERE a.counter_name='Cache Hit Ratio' AND a.OBJECT_NAME='{$MSSQL.INSTANCE}:Plan Cache' AND instance_name='_Total'