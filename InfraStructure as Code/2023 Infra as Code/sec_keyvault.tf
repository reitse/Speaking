resource "azurerm_key_vault" "kv_main" {
  location            = azurerm_resource_group.rg_security.location
  resource_group_name = azurerm_resource_group.rg_security.name

  tags      = var.tags
  name      = var.Keyvault_name
  tenant_id = var.tenant_id
  sku_name  = "standard"

  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  enable_rbac_authorization   = true

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules = ["${trim(data.http.myip.response_body, "\n")}/32"]
    virtual_network_subnet_ids = [azurerm_subnet.snet_vm.id,azurerm_subnet.snet_db.id]
  }
  depends_on = [
  ]
}

resource "azurerm_private_endpoint" "pep_keyvault" {
  name                = "pep${azurerm_key_vault.kv_main.name}"
  location            = azurerm_resource_group.rg_connectivity.location
  resource_group_name = azurerm_resource_group.rg_connectivity.name
  subnet_id           = azurerm_subnet.snet_db.id

  private_service_connection {
    name                           = "KeyvaultPrivateServiceLink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.kv_main.id
    subresource_names              = ["vault"]
  }
}