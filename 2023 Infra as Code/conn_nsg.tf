resource "azurerm_network_security_group" "nsg_vnet"{
    name                    = var.Network_Security_Group_VNET_Name
    location                = azurerm_resource_group.rg_connectivity.location
    resource_group_name     = azurerm_resource_group.rg_connectivity.name
    tags                    = var.tags
}

resource "azurerm_network_security_group" "nsg_vm"{
    name                    = var.Network_Security_Group_VM_Name
    location                = azurerm_resource_group.rg_connectivity.location
    resource_group_name     = azurerm_resource_group.rg_connectivity.name
    tags                    = var.tags
}

resource "azurerm_network_security_group" "nsg_db"{
    name                    = var.Network_Security_Group_DB_Name
    location                = azurerm_resource_group.rg_connectivity.location
    resource_group_name     = azurerm_resource_group.rg_connectivity.name
    tags                    = var.tags
}

resource "azurerm_subnet_network_security_group_association" "snet_bst_nsg"{
    subnet_id                   = azurerm_subnet.snet_bastion.id
    network_security_group_id   = azurerm_network_security_group.nsg_vnet.id
}

resource "azurerm_network_interface_security_group_association" "snet_vm_nsg"{
    network_interface_id = azurerm_network_interface.vmnic.id
    network_security_group_id = azurerm_network_security_group.nsg_vm.id
}

/*
    Manually associate your NSG with the NIC belonging to the Private endpoint of the DB
*/