/*
Copyright 2021 Reitse Eskens

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

create or alter procedure usp_check_datalength

as
SET NOCOUNT ON

IF NOT EXISTS (select * from sysobjects where name='DataLengthAnalysis' and xtype='U')

create table dbo.DataLengthAnalysis
(
	schemaname varchar(15),
	tablename varchar(100),
	schema_table_column_name varchar(300) primary key,
	max_length_in_column int,
	max_length_by_column_definition int,
	optimizer_expects_length int,
	row_count int,
	percentage_column_width_used decimal(12,8),
	difference_max_length_column_width int,
	too_large_factor decimal(12,8)
)


declare @truncatequery nvarchar(50),
		@selectquery nvarchar(2500)

declare  dataCursor cursor FOR

select  'insert into dbo.DataLengthAnalysis 
		select ''' + s.name + ''' as schemaname, ' + 
		'''' + t.name + ''' as tablename, ' +
		'''' + s.name + '.' + t.name + '.' + c.name + ''' as schema_table_column_name, ' +
		'max(len([' + c.name + '])) as max_length_in_column, ' +
		cast(case c.max_length when -1 then 8000 else c.max_length end as varchar(30))+ ' as max_length_by_column_definition, '  + 
		cast((case c.max_length when -1 then 8000 else c.max_length end/2) as varchar(30))+ ' as optimizer_expects_length,
		count(1) as row_count,
		max(len([' + c.name + '])) / cast(' + cast(case c.max_length when -1 then 8000 else c.max_length end as varchar(30)) +' as decimal(8,2))*100.00 as percentage_column_width_used,
		max(len([' + c.name + ']))-' + cast(case c.max_length when -1 then 8000 else c.max_length end as varchar(30)) +'   as difference_max_length_column_width,
		max(len([' + c.name + ']))/cast(' + cast(case c.max_length when -1 then 8000 else c.max_length end as varchar(30)) + ' as decimal(8,2)) as too_large_factor
		from [' + s.name + '].[' + t.name +']'  
from sys.tables t
inner join sys.columns c on t.object_id = c.object_id
inner join sys.types tp on c.system_type_id = tp.system_type_id
inner join sys.schemas s on t.schema_id = s.schema_id
where (tp.name like '%char%'
and c.max_length > 10 )
or (c.max_length = -1 and tp.name like '%char%')
--order by max_length
order by s.name, t.name, c.name

set @truncatequery = 'truncate table dbo.DataLengthAnalysis';

exec sp_executesql @truncatequery;

open  datacursor

Fetch next from datacursor into @selectquery

while @@FETCH_STATUS = 0

begin

	exec sp_executesql @selectquery;
	Fetch next from datacursor into @selectquery

end

close datacursor
deallocate datacursor