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

/* Check the resource governor pool */
SELECT * from sys.dm_resource_governor_resource_pools
where name = 'default'