resource "azurerm_network_security_rule" "AllowGatewayInboundFnd" {
  name                                  = "nsgsr-allow-gateway-inbound"
  priority                              = 100
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_range                = "443"
  source_address_prefix                 = "GatewayManager"
  destination_address_prefix            = "*"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
  description                           = "Allow the Azure Gateway manager inbound"
}

resource "azurerm_network_security_rule" "AllowBastionHostInboundFnd" {
  name                                  = "nsgsr-allow-bastion-host-communication-inbound"
  priority                              = 110
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_ranges               = ["8080", "5701"]
  source_address_prefix                 = "VirtualNetwork"
  destination_address_prefix            = "VirtualNetwork"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
  description                           = "Rule to allow Azure Bastion inbound traffic for secure remote desktop services"
}
resource "azurerm_network_security_rule" "AllowBastionInboundFnd" {
  name                                  = "nsgsr-allow-bastion-inbound"
  priority                              = 120
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_ranges               = ["22", "3389"]
  description                           = "NSG rule to allow Bastion connections to the virtual network"
  source_address_prefixes               = azurerm_virtual_network.vnet_main.address_space
  destination_address_prefix            = "VirtualNetwork"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name

}

resource "azurerm_network_security_rule" "AllowSQLInboundFnd" {
  name                                  = "nsgsr-allow-sql-inbound"
  priority                              = 130
  direction                             = "Inbound"
  access                                = "Allow"         
  protocol                              = "*"         
  source_port_range                     = "*"         
  destination_port_ranges               = ["1433-1434"]
  description                           = "NSG rule to allow connection to SQL database" 
  source_address_prefixes               = azurerm_virtual_network.vnet_main.address_space
  destination_address_prefix            = azurerm_private_endpoint.pep_sql.private_service_connection.0.private_ip_address
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
}         

resource "azurerm_network_security_rule" "AllowAzureStorageInboundFnd" {
  name                                  = "nsgsr-allow-azure-storage-inbound"
  priority                              = 140
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_range                = "445"
  source_address_prefix                 = "Storage"
  destination_address_prefix            = "VirtualNetwork"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
  description                           = "nsg rule to allow inbound connection to the Azure storage"
}

resource "azurerm_network_security_rule" "AllowAzureDlsInboundFnd" {
  name                                  = "nsgsr-allow-azure-dls-inbound"
  priority                              = 150
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_range                = "443"
  source_address_prefix                 = "Storage"
  destination_address_prefix            = "VirtualNetwork"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
  description                           = "nsg rule to allow inbound connection to the Azure data lake"
}

resource "azurerm_network_security_rule" "AllowAzureLoadBalancerInBoundFnd" {
  name                                  = "nsgsr-allow-azure-loadbalancer-inbound"
  priority                              = 4095
  direction                             = "Inbound"
  access                                = "Allow"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_range                = "*"
  description                           = "nsg rule to allow the Azure Load Balancer to function" 
  source_address_prefix                 = "AzureLoadBalancer"
  destination_address_prefix            = "*"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
}

resource "azurerm_network_security_rule" "IngressDenyAllFnd" {
  name                                  = "nsgsr-deny-all-ingress"
  priority                              = 4096
  direction                             = "Inbound"
  access                                = "Deny"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_range                = "*"
  description                           = "nsg rule from Zero Trust, deny all other inbound connections."
  source_address_prefix                 = "*"
  destination_address_prefix            = "*"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
}