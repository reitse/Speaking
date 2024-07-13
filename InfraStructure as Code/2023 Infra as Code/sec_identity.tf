resource "azurerm_user_assigned_identity" "id_default"{
    resource_group_name     = azurerm_resource_group.rg_identity.name
    location                = azurerm_resource_group.rg_identity.location
    name                    = var.Managed_identity_name
}