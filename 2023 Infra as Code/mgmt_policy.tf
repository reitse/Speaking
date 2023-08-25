resource "azurerm_policy_definition" "pol_vm_sku" {
  name                = "pol_vm_sku"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Data Saturday VM SKU Policy"
  management_group_id = var.management_group_id

  metadata = <<METADATA
    {
        "category": "User Custom Policies"
    }
METADATA

  policy_rule = <<POLICY_RULE
{
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Compute/virtualMachines"
          },
          {
            "not": {
              "field": "Microsoft.Compute/virtualMachines/sku.name",
              "in": "[parameters('listOfAllowedSKUs')]"
            }
          }
        ]
      },
      "then": {
        "effect": "Deny"
      }
    }
POLICY_RULE


  parameters = <<PARAMETERS
{
    "listOfAllowedSKUs": {
        "metadata": {
            "description": "The list of allowed VM SKU's for resources.",
            "displayName": "Allowed SKUs",
            "strongType": "SKU"
        },
        "type": "Array"
    }
}
PARAMETERS
}