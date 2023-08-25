

resource "azurerm_mssql_database" "maindb" {
  name                             = var.Sql_db_name
  server_id                        = azurerm_mssql_server.sqlserver.id 
  collation                        = var.Sql_db_collation
  sku_name                         = var.db_sku
  zone_redundant                   = false
  tags = var.tags

    lifecycle {
    ignore_changes = [
      sku_name
    ]
  }
}

/*
Lifecycle for the SKU Name added so changes can occur from the Azure Portal
without impacting a new terraform plan/apply
*/