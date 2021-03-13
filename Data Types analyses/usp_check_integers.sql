create or alter procedure dbo.usp_check_integers (
	@schema varchar(50) = 'dbo',
	@table varchar(200) = null)

as
set nocount on

declare @sqlQuery nvarchar(4000),
		@dynamicPart varchar(500),
		@masterSQL nvarchar(3500)

set @dynamicPart = ' where 1 = 1'

IF @schema = 'All'
begin
	set @dynamicPart = @dynamicPart
end

IF @schema is not null and @table is null
begin
	set @dynamicPart += ' and s.name = ''' + @schema + ''''
end

if @schema is not null and @table is not null
begin
	set @dynamicPart += ' and s.name = ''' + @schema + ''' and t.name = ''' + @table + ''''
end

if @schema is null and @table is not null
begin
	raiserror(1,1,1)
end



set @masterSQL = 
	'insert into #querytext select ''insert into #tempresults select max('' + QUOTENAME(c.name) +'') as maxvalue, '''''' 
		+ case ct.name when ''decimal'' then concat(ct.name,''('',c.precision,''.'',c.scale,'')'')
			else ct.name end + '''''' as typename, ''''''
		+ c.name + '''''' as columnname, 
		case 
			when ISNULL(max('' + QUOTENAME(c.name) +''),0) >= 0 and  ISNULL(max('' + QUOTENAME(c.name) +''),0)  < 256 then ''''tinyint mogelijk''''
			when ISNULL(max('' + QUOTENAME(c.name) +''),0) > 255 and ISNULL(max('' + QUOTENAME(c.name) +''),0)  < 32768 then ''''smallint mogelijk''''
			when ISNULL(max('' + QUOTENAME(c.name) +''),0) > 32767 and ISNULL(max('' + QUOTENAME(c.name) +''),0) < 2147483648 then ''''int mogelijk''''
			when ISNULL(max('' + QUOTENAME(c.name) +''),0) > 2147483647 and ISNULL(max('' + QUOTENAME(c.name) +''),0) < 9223372036854775808 then ''''bigint mogelijk''''
			else ''''go decimal, may the force be with you'''' end as advice,
			case '''''' + ct.name + ''''''
				when ''''tinyint'''' then 255 - ISNULL(max('' + QUOTENAME(c.name) +''),0) 
				when ''''smallint'''' then 32767 - ISNULL(max('' + QUOTENAME(c.name) +''),0) 
				when ''''int'''' then 2147483647 - ISNULL(max('' + QUOTENAME(c.name) +''),0) 
				when ''''bigint'''' then 9223372036854775807 - ISNULL(max('' + QUOTENAME(c.name) +''),0) 
				when ''''decimal'''' then replicate(9,('' + CAST(c.precision as varchar(2)) + '' - '' + CAST(c.scale as varchar(2)) + '')) - ISNULL(max('' + QUOTENAME(c.name) +''),0)
				else -99 end as [free range],''''''
				+ t.name + '''''' as tablename, ''''''
				+ s.name + '''''' as schemaname,
				case '''''' +  ct.name + '''''' when ''''decimal'''' then
				max(PARSENAME('' + quotename(c.name) + '',1) ) else 0 end as maxprecision
			from '' 
		+ QUOTENAME(s.name) + ''.'' + QUOTENAME(t.name) 
from sys.tables t
inner join sys.columns c on t.object_id = c.object_id
inner join sys.types ct on c.system_type_id = ct.system_type_id
		and ct.name in (''tinyint'',''smallint'',''int'',''bigint'',''decimal'')
inner join sys.schemas s on t.schema_id = s.schema_id' + @dynamicPart

-- print @masterSQL

create table #querytext (query nvarchar(4000))

create table #tempResults
(
	maxvalue decimal(38,0),
	typename varchar(10),
	columnname varchar(100),
	advice varchar(50),
	[free range] decimal(38,0),
	tablename varchar(200),
	schemaname varchar(50),
	maxprecision bigint
)

exec sp_executesql @masterSQL

declare crs cursor for
select query from #querytext

open crs

fetch next from crs into @sqlQuery

while @@FETCH_STATUS = 0

begin

		exec sp_executesql @sqlQuery;

		fetch next from crs into @sqlQuery

end

close crs
deallocate crs

select schemaname, tablename, columnname, typename, maxvalue, maxprecision, [free range], advice
from #tempResults
order by [free range] desc

drop table #tempResults
drop table #querytext