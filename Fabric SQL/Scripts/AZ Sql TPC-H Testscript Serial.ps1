# Code setup
# - Connect to Azure Sql Instance
# - Set the sku of the Azure Sql Instance
# - Azure SQL VM
# - Standard S2
# - Standard S7
# - Premium P2
# - Premium P6
# - General Purpose Gen5 4 vCores
# - General Purpose Gen5 8 vCores
# - General Purpose Gen5 16 vCores
# - Hyperscale Gen5 4 vCores
# - Hyperscale Gen5 8 vCores
# - Hyperscale Gen5 16 vCores
# - Hyperscale Premium Gen5 4 vCores
# - Hyperscale Premium Gen5 8 vCores
# - Hyperscale Premium Gen5 16 vCores
# - Business Critical Gen5 4 vCores
# - Business Critical Gen5 8 vCores
# - Business Critical Gen5 16 vCores
# - Managed Instance General Purpose Gen5 4 vCores
# - Managed Instance General Purpose Gen5 8 vCores
# - Managed Instance General Purpose Gen5 16 vCores
# - Create a new table
# - Insert data into the table
# - Get the insert performance from the DBA Tools module
# - Drop the table
# - Change the sku of the Azure Sql Instance
# - Repeat

Clear-Host
Connect-AzAccount -Tenant '342aadff-00be-4b66-b988-d9dda9cebb47' -SubscriptionId '930e12cf-f1a6-4954-9765-4a5b82c7e98e'
Get-AzContext
#Connect to the Azure Sql Instance

$sqlCred = Get-Credential DbaToolsLogin
$server = Connect-DbaInstance -SqlInstance [].database.windows.net -SqlCredential $sqlCred

$skuArray = @("S2", "S7", "P2", "P6", "GP_Gen5_4", "GP_Gen5_8", "GP_Gen5_16", 
            "HS_Gen5_4", "HS_Gen5_8", "HS_Gen5_16", "HS_PRMS_4", "HS_PRMS_8", "HS_PRMS_16", 
            "BC_Gen5_4", "BC_Gen5_8", "BC_Gen5_16 vCores")



foreach ($sku in $skuArray){

        IF($sku -eq "S2" -or $sku -eq "S7"){
            $edition = "Standard"
        }
        IF($sku -eq "P2" -or $sku -eq "P6"){
            $edition = "Premium"
        }
        IF($sku -eq "GP_Gen5_4" -or $sku -eq "GP_Gen5_8" -or $sku -eq "GP_Gen5_16"){
            $edition = "GeneralPurpose"
        }
        IF ($sku -eq "HS_Gen5_4" -or $sku -eq "HS_Gen5_8" -or $sku -eq "HS_Gen5_16" -or $sku -eq "HS_PRMS_4" -or $sku -eq "HS_PRMS_8" -or $sku -eq "HS_PRMS_16"){
            $edition = "Hyperscale"
        }
        IF ($sku -eq "BC_Gen5_4" -or $sku -eq "BC_Gen5_8" -or $sku -eq "BC_Gen5_16"){
            $edition = "BusinessCritical"
        }

        Write-Host "Setting sku to $sku with Edition $edition" -ForegroundColor Green
            Set-AzSqlDatabase -ResourceGroupName "[]" `
                              -DatabaseName "[]" `
                              -ServerName "[]" `
                              -Edition $edition `
                              -RequestedServiceObjectiveName $sku

        Write-Host "Dropping old tables" -ForegroundColor Yellow

            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS nation;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS region;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS supplier;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS part;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS customer;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS partsupp;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS orders;"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "DROP TABLE IF EXISTS lineitem;"

        Write-Host "Creating a new tables" -ForegroundColor Green

            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE nation ( n_nationkey INT, n_name NVARCHAR(25), n_regionkey INT, n_comment NVARCHAR(152), n_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE region ( r_regionkey INT, r_name NVARCHAR(25), r_comment NVARCHAR(152), r_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE supplier ( s_suppkey INT, s_name NVARCHAR(25), s_address NVARCHAR(40), s_nationkey INT, s_phone NVARCHAR(15), s_acctbal DECIMAL(15,2), s_comment NVARCHAR(101), s_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE part ( p_partkey INT, p_name NVARCHAR(55), p_mfgr NVARCHAR(25), p_brand NVARCHAR(10), p_type NVARCHAR(25), p_size INT, p_container NVARCHAR(10), p_retailprice DECIMAL(15,2), p_comment NVARCHAR(23), p_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE customer ( c_custkey INT, c_name NVARCHAR(25), c_address NVARCHAR(40), c_nationkey INT, c_phone NVARCHAR(15), c_acctbal DECIMAL(15,2), c_mktsegment NVARCHAR(10), c_comment NVARCHAR(117), c_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE partsupp ( ps_partkey INT, ps_suppkey INT, ps_availqty INT, ps_supplycost DECIMAL(15,2), ps_comment NVARCHAR(199), ps_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE orders ( o_orderkey INT, o_custkey INT, o_orderstatus NVARCHAR(1), o_totalprice DECIMAL(15,2), o_orderdate DATE, o_orderpriority NVARCHAR(15), o_clerk NVARCHAR(15), o_shippriority INT, o_comment NVARCHAR(79), o_empty varchar(1) NULL );"
            Invoke-DbaQuery -SqlInstance $Server -Database sqldbmvpperf -Query "CREATE TABLE lineitem ( l_orderkey INT, l_partkey INT, l_suppkey INT, l_linenumber INT, l_quantity DECIMAL(15,2), l_extendedprice DECIMAL(15,2), l_discount DECIMAL(15,2), l_tax DECIMAL(15,2), l_returnflag NVARCHAR(1), l_linestatus NVARCHAR(1), l_shipdate DATE, l_commitdate DATE, l_receiptdate DATE, l_shipinstruct NVARCHAR(25), l_shipmode NVARCHAR(10), l_comment NVARCHAR(44), l_empty varchar(1) NULL );"

        Write-Host "Inserting data into the table" -ForegroundColor Green

        #Create the logfile
        $source = "Laptop"

        Out-File .\$edition$sku$source.txt -NoClobber

        $fileNames = @("nation.tbl", "region.tbl", "supplier.tbl.1", "part.tbl.1", "customer.tbl.1", "partsupp.tbl.1", "orders.tbl.1", "lineitem.tbl.1")

        foreach ($fileName in $fileNames){

            Write-Host "Load $fileName" -ForegroundColor Green
            $PeriodPos = $fileName.IndexOf(".")
            $tableName = $fileName.Substring(0, $PeriodPos)

            Import-DbaCsv -SqlInstance $Server -Database [] `
                                                 -Path D:\[]\$fileName `
                                                 -Delimiter '|' `
                                                 -Table $tableName `
                                                 -Schema dbo `
                                                 -NoHeaderRow | Out-File .\$edition$sku$source.txt -Append

        }

}