resource "azurerm_management_group_policy_assignment" "pol_as_vm_sku" {
  name                 = "pol_as_vm_sku"
  management_group_id  =  var.management_group_id
  policy_definition_id = azurerm_policy_definition.pol_vm_sku.id
  description          = "Policy assignment to prevent large Virtual Machines"
  display_name         = "Virtual Machine Policy Assignment"
  metadata             = <<METADATA
    {
      "category": "User Custom Policies"
    }
METADATA

  parameters = <<PARAMETERS
{
    "listOfAllowedSKUs": {
        "value": [
            "standard_D2ads_v5",
            "standard_D2ds_v5",
            "standard_D4ads_v5",
            "standard_D4ds_v5",
            "standard_D8ads_v5",
            "standard_D8ds_v5",
            "standard_D2as_v4",
            "standard_D2ds_v4",
            "standard_D4as_v4",
            "standard_D4ds_v4",
            "standard_D8as_v4",
            "standard_D8ds_v4",
            "standard_B2s",
            "standard_B2ms",
            "standard_B4ms",
            "standard_B8ms",
            "standard_B12ms",
            "standard_F2s_v2",
            "standard_F4s_v2",
            "standard_F8s_v2"
        ]
    }
}
PARAMETERS
}