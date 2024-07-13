resource "azurerm_mssql_server" "sqlserver" {
  name                         = var.Sql_Instance_Name
  resource_group_name          = azurerm_resource_group.rg_data.name
  location                     = azurerm_resource_group.rg_data.location
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.sqlservadminpw.result
  public_network_access_enabled = true
  version                       = "12.0"

  identity {
    type = "SystemAssigned"
  }
/*
  azuread_administrator {
    login_username              = "SG Maestro SQL Admins"
    azuread_authentication_only = true
    object_id                   = var.admin_group_principal_ids.sql_admins
  }
*/
  connection_policy = "Redirect"

  tags = var.tags
}

resource "azurerm_mssql_virtual_network_rule" "sql_vnetrule_subnet" {
  name      = "${azurerm_mssql_server.sqlserver.name}-vnet-rule"
  server_id = azurerm_mssql_server.sqlserver.id
  subnet_id = azurerm_subnet.snet_vm.id
}


resource "azurerm_mssql_firewall_rule" "sql_vnetrule_deployment_ip" {
  name      = "AllowDeploymentIP"
  server_id = azurerm_mssql_server.sqlserver.id

  start_ip_address = trim(data.http.myip.response_body, "\n")
  end_ip_address   = trim(data.http.myip.response_body, "\n")
}

resource "azurerm_private_endpoint" "pep_sql" {
  name                = "pep${azurerm_mssql_server.sqlserver.name}"
  location            = azurerm_resource_group.rg_data.location
  resource_group_name = azurerm_resource_group.rg_data.name
  subnet_id           = azurerm_subnet.snet_db.id


  private_service_connection {
    name                           = "pep${azurerm_mssql_server.sqlserver.name}"
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_mssql_server.sqlserver.id
    subresource_names              = ["sqlServer"]
  }

  tags = var.tags
}