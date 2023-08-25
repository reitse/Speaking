resource "azurerm_key_vault_secret" "vmpw" {
  key_vault_id = azurerm_key_vault.kv_main.id
  name         = "vmAdminPassword"
  value        = random_password.vmpw.result
  depends_on = [
    azurerm_key_vault.kv_main
  ]
}

resource "azurerm_key_vault_secret" "sqladminpw"{
  key_vault_id  = azurerm_key_vault.kv_main.id
  name          = "Sql-Administrator-Password"
  value         = random_password.sqlservadminpw.result
  depends_on = [
    azurerm_key_vault.kv_main
  ]
}