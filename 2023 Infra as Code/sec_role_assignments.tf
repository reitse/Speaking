data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "currentuser" {
}

resource "azurerm_role_assignment" "ra_kv_admin" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.currentuser.object_id
}