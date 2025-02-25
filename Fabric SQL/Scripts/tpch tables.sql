

/****** Object:  Table [dbo].[customer]    Script Date: 1-5-2024 14:36:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[customer]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[customer](
	[c_custkey] [bigint] NOT NULL,
	[c_name] [varchar](25) NOT NULL,
	[c_address] [varchar](40) NOT NULL,
	[c_nationkey] [int] NOT NULL,
	[c_phone] [char](15) NOT NULL,
	[c_acctbal] [float] NOT NULL,
	[c_mktsegment] [char](10) NOT NULL,
	[c_comment] [varchar](117) NOT NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[customer] TO  SCHEMA OWNER 
GO




/****** Object:  Table [dbo].[lineitem]    Script Date: 1-5-2024 14:36:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[lineitem]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[lineitem](
	[l_orderkey] [bigint] NOT NULL,
	[l_partkey] [bigint] NOT NULL,
	[l_suppkey] [bigint] NOT NULL,
	[l_linenumber] [bigint] NOT NULL,
	[l_quantity] [float] NOT NULL,
	[l_extendedprice] [float] NOT NULL,
	[l_discount] [float] NOT NULL,
	[l_tax] [float] NOT NULL,
	[l_returnflag] [char](1) NOT NULL,
	[l_linestatus] [char](1) NOT NULL,
	[l_shipdate] [date] NOT NULL,
	[l_commitdate] [date] NOT NULL,
	[l_receiptdate] [date] NOT NULL,
	[l_shipinstruct] [char](25) NOT NULL,
	[l_shipmode] [char](10) NOT NULL,
	[l_comment] [varchar](44) NOT NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[lineitem] TO  SCHEMA OWNER 
GO



/****** Object:  Table [dbo].[nation]    Script Date: 1-5-2024 14:36:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[nation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[nation](
	[n_nationkey] [int] NOT NULL,
	[n_name] [char](25) NOT NULL,
	[n_regionkey] [int] NOT NULL,
	[n_comment] [varchar](152) NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[nation] TO  SCHEMA OWNER 
GO



/****** Object:  Table [dbo].[orders]    Script Date: 1-5-2024 14:36:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[orders]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[orders](
	[o_orderkey] [bigint] NOT NULL,
	[o_custkey] [bigint] NOT NULL,
	[o_orderstatus] [char](1) NOT NULL,
	[o_totalprice] [float] NOT NULL,
	[o_orderdate] [date] NOT NULL,
	[o_orderpriority] [char](15) NOT NULL,
	[o_clerk] [char](15) NOT NULL,
	[o_shippriority] [int] NOT NULL,
	[o_comment] [varchar](79) NOT NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[orders] TO  SCHEMA OWNER 
GO



/****** Object:  Table [dbo].[part]    Script Date: 1-5-2024 14:37:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[part]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[part](
	[p_partkey] [bigint] NOT NULL,
	[p_name] [varchar](55) NOT NULL,
	[p_mfgr] [char](25) NOT NULL,
	[p_brand] [char](10) NOT NULL,
	[p_type] [varchar](25) NOT NULL,
	[p_size] [int] NOT NULL,
	[p_container] [char](10) NOT NULL,
	[p_retailprice] [float] NOT NULL,
	[p_comment] [varchar](23) NOT NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[part] TO  SCHEMA OWNER 
GO



/****** Object:  Table [dbo].[partsupp]    Script Date: 1-5-2024 14:37:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[partsupp]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[partsupp](
	[ps_partkey] [bigint] NOT NULL,
	[ps_suppkey] [bigint] NOT NULL,
	[ps_availqty] [bigint] NOT NULL,
	[ps_supplycost] [float] NOT NULL,
	[ps_comment] [varchar](199) NOT NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[partsupp] TO  SCHEMA OWNER 
GO


/****** Object:  Table [dbo].[region]    Script Date: 1-5-2024 14:37:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[region]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[region](
	[r_regionkey] [int] NOT NULL,
	[r_name] [char](25) NOT NULL,
	[r_comment] [varchar](152) NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[region] TO  SCHEMA OWNER 
GO


/****** Object:  Table [dbo].[supplier]    Script Date: 1-5-2024 14:38:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[supplier]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[supplier](
	[s_suppkey] [bigint] NOT NULL,
	[s_name] [char](25) NOT NULL,
	[s_address] [varchar](40) NOT NULL,
	[s_nationkey] [int] NOT NULL,
	[s_phone] [char](15) NOT NULL,
	[s_acctbal] [float] NOT NULL,
	[s_comment] [varchar](101) NOT NULL
) ON [PRIMARY]
END
GO

ALTER AUTHORIZATION ON [dbo].[supplier] TO  SCHEMA OWNER 
GO

create schema dim;
go

create schema fact;
go

create table dim.nations
(
	NationID int primary key,
	NationName varchar(50),
	NationComment varchar(150),
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime
);

create table dim.regions
(
	RegionID int primary key,
	RegionName varchar(50),
	RegionComment varchar(150),
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime
);

create table dim.[date]
(
	DateID int Identity(1,1) not null primary key,
	FullDate date,
	DateYear int,
	DateQuarter int,
	DateMonth int,
	DateDay int,
	DateMonthName varchar(15),
	DateIsoWeek int,
	DateDayName varchar(10),
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime
);

create table dim.supplier
(
	SupplierID int primary key,
	SupplierName varchar(50),
	SupplierAddress varchar(50),
	SupplierPhone varchar(25),
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime
);

create table dim.customer
(
	CustomerID int primary key,
	CustomerName varchar(50),
	CustomerAddress varchar(50),
	CustomerPhone varchar(25),
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime
);

create table dim.parts
(
	ID int identity(1,1) primary key,
	PartID int ,
	PartName varchar(80),
	PartMfgr varchar(50),
	PartBrand varchar(50),
	PartType varchar(50),
	PartSize varchar(50),
	PartContainer varchar(50),
	PartRetailPrice money,
	PartSupplierCost money,
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime
);

create table fact.orders
(
	OrderKey int identity(1,1) primary key,
	OrderID int,
	DateID int,
	CustomerID int,
	SupplierID int,
	PartID int,
	CustomerNationID int,
	CustomerRegionID int,
	SupplierNationID int,
	SupplierRegionID int,
	LineNumber int,
	LineQuantity int,
	LineDiscount int,
	IsActual bit,
	CreateDate datetime,
	ChangeDate datetime,
	DeleteDate datetime,
	constraint FK_Order_Date foreign key (DateID) references dim.date(DateID),
	constraint FK_Order_Customer foreign key (CustomerID) references dim.customer(CustomerID),
	constraint FK_Order_Supplier foreign key (SupplierID) references dim.supplier(SupplierID),
	constraint FK_Order_Part foreign key (PartID) references dim.parts(ID),
	constraint FK_Order_Customer_Nation foreign key (CustomerNationID) references dim.nations(NationID),
	constraint FK_Order_Supplier_Nation foreign key (SupplierNationID) references dim.nations(NationID),
	constraint FK_Order_Customer_Region foreign key (CustomerRegionID) references dim.regions(RegionID),
	constraint FK_Order_Supplier_Region foreign key (SupplierRegionID) references dim.regions(RegionID)
)

