/*
The variables file can offer a centralised view to maintain the configuration of your environment.
If you locate all of these here, you'll always know where to look when there are questions on naming, ranges or SKU's
The more you build in one solution, the bigger this file can get. You can always split these deployments up if necessary.
*/

/*
    GENERAL SETTINGS
*/

variable "tags"{
    type = map(any)
    default = {
        Deployment = "Terraform"
        Landing_Zone = "Analytics"
        Owner = "Reitse Eskens"
        Cost_Center = "TBD"
        Environment = "Data Saturday Demo"
    }
}

variable "location"{
    type = string
    default = "West Europe"
    description = "Location where the resources land"
}

variable "management_group_id" {
    type = string
    default = "/providers/Microsoft.Management/managementGroups/DataSaturday"
    description = "ID of the management group hosting all the subsciptions"
  
}

variable "tenant_id" {
    type = string
    default = "342aadff-00be-4b66-b988-d9dda9cebb47"
    description = "ID of the tenant, used for the Key Vault deployment"
}

variable "subscription_id"{
    type = string
    default = "814facf9-bf12-4ee9-abee-3cd632b1dcbe"
    description = "ID of the subscription, used for either multi-subscription deployments and/or making sure you deploy in the correct environment."
}

/*
    RESOURCE GROUP NAMING
*/

variable "identity_resourcegroup_name"{
    type = string
    default = "rg_identity"
    description = "Name of the Identity Resource Group where all managed identities will be located"
}

variable "connectivity_resourcegroup_name"{
    type = string
    default = "rg_connectivity"
    description = "Name of the Connectivity Resource Group where all network related resources will be located"
}

variable "security_resourcegroup_name"{
    type = string
    default = "rg_security"
    description = "Name of the Security Resource Group where all the security related resources will be located"
}

variable "data_resourcegroup_name"{
    type = string
    default = "rg_data"
    description = "Name of the Data Resource Group where all the data related resources will be located"
}

/*
    VIRTUAL NETWORK NAME AND CIDR
*/

variable "virtual_network_name"{
    type = string
    default = "vnetcentral"
    description = "Name of the central Virtual Network"
}

variable "virtual_network_cidr" {
    type = string
    default = "10.1.0.0/20"
    description = "CIDR Range for the Virtual Network"
  
}

/*
    SUBNET NAMING AND CIDR SETTING
*/
variable "VPN_subnet_name" {
    type = string
    default = "GatewaySubnet"
    description = "Name of the subnet for the VPN. Do not change this!"
  
}

variable "Bastion_subnet_name"{
    type = string
    default = "AzureBastionSubnet"
    description = "Name of the subnet for Azure Bastion. Do not change this!"
}

variable "Database_subnet_name" {
    type = string
    default = "snetDatabases"
    description = "Name of the subnet for all other resources"
}

variable "Vm_subnet_name" {
    type = string
    default = "snetVirtualMachines"
    description = "Name of the subnet for all other resources"
}

variable "subnet_range_bytes"{
    type = number
    default = 4
    description = "Amount of bytes reserved for each subnet, starting at the CIDR root of the VNET. A /20 will result in /24 subnets with range bytes = 4"
}

/*
    NETWORK SECURITY GROUP NAMING
*/

variable "Network_Security_Group_VNET_Name" {
    type = string
    default = "nsgdefaultvnet"
    description = "Name of the NSG for the virtual network"
}

variable "Network_Security_Group_VM_Name" {
    type = string
    default = "nsgdefaultvm"
    description = "Name of the NSG for the virtual network"
}

variable "Network_Security_Group_DB_Name" {
    type = string
    default = "nsgdefaultdb"
    description = "Name of the NSG for the virtual network"
}

/*
    MANAGED IDENTITY NAMING
*/

variable "Managed_identity_name" {
  type = string
  default = "iddatasaturdayrocks"
  description = "Name of the managed identity used to connect Azure resources, in this case the data factory to the database"
}

/*
    RESOURCE NAMING
*/

variable "Keyvault_name" {
    type = string
    default = "kvdatasat23"
    description = "Name of the Key Vault"
}

variable "Datafactory_name" {
    type = string
    default = "adfdatasat23"
    description = "Name of the Azure Data Factory"
}

variable "Sql_Instance_Name" {
    type = string
    default = "sqldatasat23"
    description = "Name of the SQL Server instance"
}

variable "Sql_db_name" {
  type = string
  default = "sqldbdatasat23"
  description = "Name of the SQL Database"
}

variable "Virtual_Machine_Name" {
    type = string
    default = "vmdatasat23"
    description = "Name of the Virtual Machine"
}

/*
    Database Collation(s)
*/

variable "Sql_db_collation" {
    type = string
    default = "SQL_Latin1_General_CP1_CI_AS"
    description = "Collation of the database."
  
}

/*
    Resource Sizing
*/

variable "vm_size" {
    type = string
    default = "Standard_F2s_v2"
    description = "Sizing variable for the Virtual Machine"
}

variable "db_sku"{
    type = string
    default = "Basic"
    description = "Sizing variable for the Azure Sql Database"
}