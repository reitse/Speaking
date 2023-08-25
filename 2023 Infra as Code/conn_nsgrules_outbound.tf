resource "azurerm_network_security_rule" "AllowSSHRDPOutboundFnd" {
  name                                  = "nsgsr-allow-ssh-rdp-outbound"
  priority                              = 100
  direction                             = "Outbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_ranges               = ["22", "3389"]
  source_address_prefix                 = "*"
  destination_address_prefix            = "VirtualNetwork"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
}

resource "azurerm_network_security_rule" "AllowBastionHostOutboundFnd" {
  name                                  = "nsgsr-allow-bastion-host-communication-outbound"
  priority                              = 110
  direction                             = "Outbound"
  access                                = "Allow"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_ranges               = ["8080", "5701"]
  source_address_prefix                 = "VirtualNetwork"
  destination_address_prefix            = "VirtualNetwork"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name

}

resource "azurerm_network_security_rule" "AllowAzureCloudOutboundFnd" {
  name                                  = "nsgsr-allow-azurecloud-outbound"
  priority                              = 120
  direction                             = "Outbound"
  access                                = "Allow"
  protocol                              = "Tcp"
  source_port_range                     = "*"
  destination_port_range                = "443"
  source_address_prefix                 = "*"
  destination_address_prefix            = "AzureCloud"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name

}

resource "azurerm_network_security_rule" "AllowInternetOutboundFnd" {
  name                                  = "nsgsr-allow-internet-outbound"
  priority                              = 130
  direction                             = "Outbound"
  access                                = "Allow"
  protocol                              = "*"
  source_port_range                     = "*"
  source_address_prefix                 = "VirtualNetwork"
  destination_port_ranges               = ["80", "443"]
  destination_address_prefix            = "Internet"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name
}

resource "azurerm_network_security_rule" "EgressDenyAllFnd" {
  name                                  = "nsgsr-deny-all-egress"
  priority                              = 4096
  direction                             = "Outbound"
  access                                = "Deny"
  protocol                              = "*"
  source_port_range                     = "*"
  destination_port_range                = "*"
  description                           = "nsg rule from Zero Trust, deny all other outbound connections."
  source_address_prefix                 = "*"
  destination_address_prefix            = "*"
  resource_group_name                   = azurerm_resource_group.rg_connectivity.name
  network_security_group_name           = azurerm_network_security_group.nsg_vnet.name

}