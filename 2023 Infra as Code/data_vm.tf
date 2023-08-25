resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.Virtual_Machine_Name
  computer_name       = substr(var.Virtual_Machine_Name,1,15)
  resource_group_name = azurerm_resource_group.rg_data.name
  location            = azurerm_resource_group.rg_data.location
  size                = var.vm_size
  admin_username      = "vmadmin"
  admin_password      = random_password.vmpw.result
  network_interface_ids = [
    azurerm_network_interface.vmnic.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.id_default.id]
  }
  encryption_at_host_enabled = true
  tags = var.tags


}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vmautoshutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  location           = azurerm_resource_group.rg_data.location
  enabled            = true

  daily_recurrence_time = "1800"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

resource "azurerm_network_interface" "vmnic" {
  name                          = "nic${var.Virtual_Machine_Name}01"
  location                      = azurerm_resource_group.rg_data.location
  resource_group_name           = azurerm_resource_group.rg_data.name
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_vm.id
    private_ip_address_allocation = "Static"
    private_ip_address = cidrhost(local.vm_prefix[0], 5 + 4)
  }

  tags = var.tags
}
