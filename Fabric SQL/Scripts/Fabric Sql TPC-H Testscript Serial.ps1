# Code setup
# - Connect to Fabric Sql Instance
# - Create a new table
# - Insert data into the table
# - Get the insert performance from the DBA Tools module
# - Drop the table

Clear-Host
#Connect to the Fabric Sql Instance

$azureAccount = Connect-AzAccount  -TenantId []
$azureToken = Get-AzAccessToken -ResourceUrl https://database.windows.net 
$azureInstance = "[].database.fabric.microsoft.com"
$azureDatabase = "[]"
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

$sku = 'Fabric'
$edition = 'SQL'

Write-Host "Dropping existing tables" -ForegroundColor Green

Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSnation;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSregion;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSsupplier;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSpart;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PScustomer;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSpartsupp;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSorders;"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "DROP TABLE IF EXISTS PSlineitem;"

Write-Host "Creating a new tables" -ForegroundColor Green

Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSnation ( n_nationkey INT, n_name NVARCHAR(25), n_regionkey INT, n_comment NVARCHAR(152), n_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSregion ( r_regionkey INT, r_name NVARCHAR(25), r_comment NVARCHAR(152), r_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSsupplier ( s_suppkey INT, s_name NVARCHAR(25), s_address NVARCHAR(40), s_nationkey INT, s_phone NVARCHAR(15), s_acctbal DECIMAL(15,2), s_comment NVARCHAR(101), s_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSpart ( p_partkey INT, p_name NVARCHAR(55), p_mfgr NVARCHAR(25), p_brand NVARCHAR(10), p_type NVARCHAR(25), p_size INT, p_container NVARCHAR(10), p_retailprice DECIMAL(15,2), p_comment NVARCHAR(23), p_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PScustomer ( c_custkey INT, c_name NVARCHAR(25), c_address NVARCHAR(40), c_nationkey INT, c_phone NVARCHAR(15), c_acctbal DECIMAL(15,2), c_mktsegment NVARCHAR(10), c_comment NVARCHAR(117), c_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSpartsupp ( ps_partkey INT, ps_suppkey INT, ps_availqty INT, ps_supplycost DECIMAL(15,2), ps_comment NVARCHAR(199), ps_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSorders ( o_orderkey INT, o_custkey INT, o_orderstatus NVARCHAR(1), o_totalprice DECIMAL(15,2), o_orderdate DATE, o_orderpriority NVARCHAR(15), o_clerk NVARCHAR(15), o_shippriority INT, o_comment NVARCHAR(79), o_empty varchar(1) NULL );"
Invoke-DbaQuery -SqlInstance $Server -Database "[]" -Query "CREATE TABLE PSlineitem ( l_orderkey INT, l_partkey INT, l_suppkey INT, l_linenumber INT, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_tax DECIMAL(15,2), l_returnflag NVARCHAR(1), l_linestatus NVARCHAR(1), l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct NVARCHAR(25), l_shipmode NVARCHAR(10), l_comment NVARCHAR(44), l_empty varchar(1) NULL );"

Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta
Write-Host "Inserting data into the table" -ForegroundColor Green

#Create the logfile
$source = "Laptop"

Out-File .\$edition$sku$source.txt -NoClobber
Write-Host "Load region" -ForegroundColor Green
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\region.tbl `
-Delimiter '|' `
-Table "PSregion" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load nation" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta


Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\nation.tbl `
-Delimiter '|' `
-Table "PSnation" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load supplier" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\supplier.tbl `
-Delimiter '|' `
-Table "PSsupplier" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load part" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\part.tbl.1 `
-Delimiter '|' `
-Table "PSpart" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load customer" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\customer.tbl.1 `
-Delimiter '|' `
-Table "PScustomer" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load partsupp" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\partsupp.tbl.1 `
-Delimiter '|' `
-Table "PSpartsupp" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load orders" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\orders.tbl.1 `
-Delimiter '|' `
-Table "PSorders" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

Write-Host "Load lineitem" -ForegroundColor Green
$server = Connect-DbaInstance -SqlInstance $azureInstance -Database $azureDatabase -AccessToken $azureToken
Write-Host "Connected to $server with token $azureToken" -ForegroundColor Magenta

Import-DbaCsv -SqlInstance $Server -Database "[]" `
-Path D:\TPCH\lineitem.tbl.1 `
-Delimiter '|' `
-Table "PSlineitem" `
-Schema dbo `
-NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

