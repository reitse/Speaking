resource "azurerm_virtual_network" "vnet_main"{
    location                = azurerm_resource_group.rg_connectivity.location
    resource_group_name     = azurerm_resource_group.rg_connectivity.name
    name                    = var.virtual_network_name
    tags                    = var.tags
    address_space           = [var.virtual_network_cidr]
}

resource "azurerm_subnet" "snet_gateway"{
    name                    = var.VPN_subnet_name
    resource_group_name     = azurerm_resource_group.rg_connectivity.name
    virtual_network_name    = azurerm_virtual_network.vnet_main.name
    address_prefixes        = local.gateway_prefix
}

resource "azurerm_subnet" "snet_bastion"{
    name                    = var.Bastion_subnet_name
    resource_group_name     = azurerm_resource_group.rg_connectivity.name
    virtual_network_name    = azurerm_virtual_network.vnet_main.name
    address_prefixes        = local.bastion_prefix
    service_endpoints         = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "snet_db" {
  name                      = var.Database_subnet_name
  resource_group_name       = azurerm_resource_group.rg_connectivity.name
  virtual_network_name      = azurerm_virtual_network.vnet_main.name
  address_prefixes          = local.database_prefix
  service_endpoints         = ["Microsoft.Sql", "Microsoft.KeyVault"]
}

resource "azurerm_subnet" "snet_vm" {
  name                      = var.Vm_subnet_name
  resource_group_name       = azurerm_resource_group.rg_connectivity.name
  virtual_network_name      = azurerm_virtual_network.vnet_main.name
  address_prefixes          = local.vm_prefix
  service_endpoints         = ["Microsoft.KeyVault"]
}