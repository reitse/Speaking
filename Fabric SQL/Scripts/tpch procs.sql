create or alter procedure sp_loadNations
as
BEGIN
	SET NOCOUNT ON;
	MERGE dim.nations AS Target
	USING (

SELECT DISTINCT
	n_nationkey as NationID,
	n_name as NationName,
	n_comment as NationComment
	FROM dbo.PSnation) AS Source
	ON Source.NationID = Target.NationID

	WHEN MATCHED 
		AND source.NationName != target.NationName
		OR source.NationComment != target.NationComment
	THEN UPDATE
		SET 
			 Target.NationName = Source.NationName,
			 Target.NationComment = Source.NationComment,
			 Target.ChangeDate = SYSDATETIME()

	WHEN NOT MATCHED BY SOURCE THEN UPDATE
		SET Target.DeleteDate = SYSDATETIME()

	WHEN NOT MATCHED BY TARGET 
	THEN 
	INSERT(NationID, NationName, NationComment, IsActual, CreateDate, ChangeDate, DeleteDate)
	VALUES (NationID, NationName, NationComment,1, SYSDATETIME(),SYSDATETIME() ,'2099-01-01' );
END

GO

create or alter procedure sp_loadRegions
as
BEGIN
	SET NOCOUNT ON
	MERGE dim.regions as Target

	USING(
	SELECT DISTINCT
		r_regionkey as RegionID,
		r_name as RegionName,
		r_comment as RegionComment
	FROM dbo.PSregion) as source
	ON target.RegionID = source.RegionID

	WHEN MATCHED 
		AND source.RegionName != target.RegionName
		OR source.RegionComment != target.RegionComment
	THEN UPDATE
		SET Target.RegionName = source.RegionName,
			Target.RegionComment = source.RegionName,
			Target.ChangeDate = Sysdatetime()

	WHEN NOT MATCHED BY SOURCE
		THEN UPDATE 
			SET DeleteDate = Sysdatetime()

	WHEN NOT MATCHED BY TARGET
		THEN 
		INSERT (RegionID, RegionName, RegionComment, IsActual, CreateDate, ChangeDate, DeleteDate)
		VALUES (RegionID, RegionName, RegionComment, 1, SYSDATETIME(),SYSDATETIME() ,'2099-01-01' );
		
END
GO


create or alter procedure sp_loadDate
as

WITH E00(N) AS (SELECT 1 UNION ALL SELECT 1)
    ,E02(N) AS (SELECT 1 FROM E00 a, E00 b)
    ,E04(N) AS (SELECT 1 FROM E02 a, E02 b)
    ,E08(N) AS (SELECT 1 FROM E04 a, E04 b)
    ,E16(N) AS (SELECT 1 FROM E08 a, E08 b)
    ,E32(N) AS (SELECT 1 FROM E16 a, E16 b)
    ,cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E32),
dates as (
SELECT ExplodedDate = DATEADD(DAY,N - 1,'1980-01-01')
FROM cteTally
WHERE N <= 18300
)
insert into dim.date (	FullDate, DateYear,	DateQuarter,DateMonth,DateDay,DateMonthName, DateIsoWeek, DateDayName,IsActual,CreateDate, ChangeDate, DeleteDate)
SELECT
	ExplodedDate as FullDate,
	YEAR(ExplodedDate) as DateYear,
	DATEPART(Quarter, ExplodedDate) as DateQuarter,
	MONTH(ExplodedDate) as DateMonth,
	DAY(ExplodedDate) as DateDay,
	DATENAME(WEEKDAY, ExplodedDate) as DateDayName,
	DATENAME(ISO_WEEK , ExplodedDate) as DateIsoWeek,
	DATENAME(Month, ExplodedDate) as DateMonthName,
	1 as IsActual,
	SYSDATETIME() as CreateDate,
	SYSDATETIME() as ChangeDate,
	'2099-01-01' as DeleteDate
from dates;
GO

create or alter procedure sp_loadSupplier
as

BEGIN
	MERGE dim.supplier as target
	USING
	( SELECT DISTINCT
		s_suppkey as SupplierID,
		s_name as SupplierName,
		s_address as SupplierAddress,
		s_phone as 	SupplierPhone
	  FROM dbo.PSsupplier) as source

	  ON source.SupplierID = target.SupplierID

	  WHEN MATCHED 
		AND source.SupplierName != target.SupplierName
		OR source.SupplierAddress != target.SupplierAddress
		or source.SupplierPhone != target.SupplierPhone
	 THEN UPDATE
		SET target.SupplierName = Source.SupplierName,
			target.SupplierAddress = source.SupplierAddress,
			target.SupplierPhone = source.SupplierPhone,
			target.ChangeDate = sysdatetime()

		WHEN NOT MATCHED BY SOURCE
		THEN UPDATE
			SET target.DeleteDate = sysdatetime()

		WHEN NOT MATCHED BY TARGET
		THEN 
		INSERT (SupplierID, SupplierNAme, SupplierAddress, SupplierPhone, IsActual, CreateDate, ChangeDate, DeleteDate)
		VALUES (SupplierID, SupplierNAme, SupplierAddress, SupplierPhone, 1, SYSDATETIME(),SYSDATETIME() ,'2099-01-01' );
END
GO


create or alter procedure sp_loadCustomer
as
BEGIN
	MERGE dim.customer as target
	USING (
	SELECT DISTINCT 
		c_custkey as CustomerID,
		c_name as CustomerName,
		c_address as CustomerAddress,
		c_phone as CustomerPhone
	FROM dbo.PScustomer) as source

	ON Source.CustomerID = target.CustomerID

	WHEN MATCHED
		AND target.CustomerName != source.CustomerName
		OR target.CustomerAddress != source.CustomerAddress
		OR target.CustomerPhone != source.CustomerPhone
	THEN UPDATE
		SET target.CustomerName = source.CustomerName,
			target.CustomerAddress = source.CustomerAddress,
			target.CustomerPhone = source.CustomerPhone,
			target.ChangeDate = Sysdatetime()

	WHEN NOT MATCHED BY SOURCE
	THEN UPDATE
		SET target.DeleteDate = SYSDATETIME()

	WHEN NOT MATCHED BY TARGET
	THEN 
	INSERT (CustomerID, CustomerName,CustomerAddress,CustomerPhone, IsActual, CreateDate, ChangeDate, DeleteDate)
	VALUES (CustomerID, CustomerName,CustomerAddress,CustomerPhone, 1, SYSDATETIME(),SYSDATETIME() ,'2099-01-01' );

END
GO

create or alter procedure sp_loadParts
as

BEGIN
	MERGE dim.parts as target
	USING
		(
			SELECT TOP 40000000
				P.p_partkey as PartID,
				P.p_name as PartName,
				P.p_mfgr as PartMfgr,
				P.p_brand as PartBrand,
				P.p_type as PartType,
				P.p_size as PartSize,
				P.p_container as PartContainer,
				P.p_retailprice as PartRetailPrice,
				PS.ps_supplycost as PartSupplierCost
				FROM dbo.PSpart P
				INNER JOIN dbo.PSpartsupp PS on P.p_partkey = PS.ps_partkey
		) AS SOURCE

		ON SOURCE.PartID = Target.PartID

		WHEN MATCHED 
			AND Target.PartName != Source.Partname
			OR Target.PartMfgr != Source.PartMfgr
			OR Target.PartBrand != Source.PartBrand
			OR Target.PartType != Source.PartBrand
			Or Target.PartSize != Source.PartSize
			Or Target.PartContainer != Source.PartContainer
			OR Target.PartRetailPrice != Source.PartRetailPrice
			Or Target.PartSupplierCost != Source.PartSupplierCost
		THEN UPDATE
			SET Target.PartName				= Source.PartName		 ,
				Target.PartMfgr 			= Source.PartMfgr		 ,
				Target.PartBrand			= Source.PartBrand		 ,
				Target.PartType 			= Source.PartType		 ,
				Target.PartSize 			= Source.PartSize		 ,
				Target.PartContainer 		= Source.PartContainer	 ,
				Target.PartRetailPrice		= Source.PartRetailPrice ,
				Target.PartSupplierCost 	= Source.PartSupplierCost  ,
				Target.ChangeDate			= Sysdatetime()

		WHEN NOT MATCHED BY SOURCE
			THEN UPDATE
				SET Target.DeleteDate = Sysdatetime()

		WHEN NOT  MATCHED BY TARGET
			THEN 
			INSERT (PartID, PartName, PartMfgr, PartBrand, PartType, PartSize, PartContainer, PartRetailPrice, PartSupplierCost, IsActual, CreateDate, ChangeDate, DeleteDate)
			VALUES (PartID, PartName, PartMfgr, PartBrand, PartType, PartSize, PartContainer, PartRetailPrice, PartSupplierCost, 1, SYSDATETIME(),SYSDATETIME() ,'2099-01-01');

END


GO

create or alter procedure sp_loadOrders
as
BEGIN
	MERGE fact.orders as TARGET

	USING ( 
		SELECT
				O.o_orderkey	as OrderID,
				DD.DateID		AS DateID,
				C.c_custkey		as CustomerID,
				S.s_suppkey		as SupplierID,
				P.ID		    AS PartID,
				NC.n_nationkey	AS CustomerNationID,
				RC.r_regionkey	AS CustomerRegionID,
				NS.n_nationkey	AS SupplierNationID,
				RS.r_regionkey	AS SupplierRegionID,
				L.l_linenumber	AS LineNumber,
				L.l_quantity	AS LineQuantity,
				L.l_discount	AS LineDiscount
		FROM dbo.PSorders O
			INNER JOIN dbo.PSlineitem L on O.o_orderkey = L.l_orderkey
			INNER JOIN dim.date DD on O.o_orderdate = DD.FullDate
			INNER JOIN dbo.PScustomer C on O.o_custkey = C.c_custkey
			INNER JOIN dim.parts P on L.l_partkey = P.PartID
			INNER JOIN dbo.PSsupplier S on L.l_suppkey = S.s_suppkey
			INNER JOIN dbo.PSnation NC on C.c_nationkey = NC.n_nationkey
			INNER JOIN dbo.PSregion RC on NC.n_regionkey = RC.r_regionkey
			INNER JOIN dbo.PSnation NS on S.s_nationkey = NS.n_nationkey
			INNER JOIN dbo.PSregion RS on NS.n_nationkey = RS.r_regionkey
		) as SOURCE
			ON Source.OrderID = Target.OrderID
				AND Source.LineNumber = Target.LineNumber

		WHEN MATCHED
			AND target.DateID				!= source.DateID
			OR	target.CustomerID			!= source.CustomerID
			OR	target.SupplierID			!= source.SupplierID
			OR	target.PartID				!= source.PartID
			OR	target.CustomerNationID		!= source.CustomerNationID
			OR	target.CustomerRegionID		!= source.CustomerRegionID
			OR	target.SupplierNationID		!= source.SupplierNationID
			OR	target.SupplierRegionID		!= source.SupplierRegionID
			OR	target.LineQuantity			!= source.LineQuantity
			OR	target.LineDiscount			!= source.LineDiscount
		THEN 
		UPDATE
		SET		target.DateID				= source.DateID
			,	target.CustomerID			= source.CustomerID
			,	target.SupplierID			= source.SupplierID
			,	target.PartID				= source.PartID
			,	target.CustomerNationID		= source.CustomerNationID
			,	target.CustomerRegionID		= source.CustomerRegionID
			,	target.SupplierNationID		= source.SupplierNationID
			,	target.SupplierRegionID		= source.SupplierRegionID
			,	target.LineQuantity			= source.LineQuantity
			,	target.LineDiscount			= source.LineDiscount
			,	target.ChangeDate			= SysdateTime()

		WHEN NOT MATCHED BY SOURCE
			THEN 
			UPDATE SET target.DeleteDate = SYSDATETIME()

		WHEN NOT MATCHED BY TARGET
			THEN
			INSERT (OrderID,DateID, CustomerID, SupplierID, PartID, CustomerNationID, CustomerRegionID, SupplierNationID, SupplierRegionID, LineQuantity, LineDiscount, LineNumber, IsActual, CreateDate, ChangeDate, DeleteDate)
			VALUES (OrderID,DateID, CustomerID, SupplierID, PartID, CustomerNationID, CustomerRegionID, SupplierNationID, SupplierRegionID, LineQuantity, LineDiscount, LineNumber, 1,SYSDATETIME(),SYSDATETIME() ,'2099-01-01');
END;
GO

CREATE OR ALTER Procedure sp_RunAllEtlToHell @new bit = 0
as
SET NOCOUNT ON
BEGIN
	print 'Process Started'
	Print sysdatetime();
	IF @new = 1
		PRINT 'Starting with dates when new'
		EXEC sp_loadDate;
		PRINT 'Finished dates'
	PRINT sysdatetime();
	PRINT 'Starting with Nations'
		EXEC sp_loadNations;
	PRINT 'Finished Nations'
	PRINT sysdatetime();
	PRINT 'Starting with Regions'
		EXEC sp_loadRegions;
	PRINT 'Finished Regions'
	PRINT sysdatetime();
	PRINT 'Starting with Customers'
		EXEC sp_loadCustomer;
	PRINT 'Finished Customers'
	PRINT sysdatetime();
	PRINT 'Starting with Supplier'
		EXEC sp_loadSupplier;
	PRINT 'Finished Supplier'
	PRINT sysdatetime();
	PRINT 'Starting with Parts'
		EXEC sp_loadParts;
	PRINT 'Finished Parts'
	PRINT sysdatetime();
	PRINT 'Starting with Orders'
		EXEC sp_loadOrders;
	PRINT 'Finished Orders'
	PRINT sysdatetime();
	PRINT 'End of Procedure'
END