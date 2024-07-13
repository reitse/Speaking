resource "azurerm_resource_group" "rg_identity"{
    name        = var.identity_resourcegroup_name
    location    = var.location
    tags        = var.tags
}

resource "azurerm_resource_group" "rg_connectivity"{
    name        = var.connectivity_resourcegroup_name
    location    = var.location
    tags        = var.tags
}

resource "azurerm_resource_group" "rg_security"{
    name        = var.security_resourcegroup_name
    location    = var.location
    tags        = var.tags
}

resource "azurerm_resource_group" "rg_data"{
    name        = var.data_resourcegroup_name
    location    = var.location
    tags        = var.tags
}
