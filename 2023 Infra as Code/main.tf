/*
The main.tf file is a required file to manage things like the providers, the required version 
but also variables that are shared between other files, like my current IP address.
The versions used here are examples, if you need functionality that is only available in newer versions,
change these settings accordingly.

*/

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.21.1"
    }
  azuread = {
    source  = "hashicorp/azuread"
    version = "~>2.15.0"
  }
  }

  required_version = ">= 1.5.0"

}

provider "azurerm" {
  features {
    
  }
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
}


data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "random_password" "vmpw" {
  length  = 20
  special = true
}

resource "random_password" "sqlservadminpw" {
  length  = 20
  special = true
}

locals {
  subnet_prefixes = cidrsubnets(var.virtual_network_cidr, var.subnet_range_bytes, var.subnet_range_bytes, var.subnet_range_bytes, var.subnet_range_bytes)

  gateway_prefix   = [local.subnet_prefixes[0]]
  bastion_prefix   = [local.subnet_prefixes[1]]
  database_prefix  = [local.subnet_prefixes[2]]
  vm_prefix        = [local.subnet_prefixes[3]]
}