provider "azurerm" {
  version = ">=2.9.0"
  features {}
}

variable "json" {
  type        = any
  description = "JSON containing all TF Vars"
}

variable "createdestroy" {
    type        = string
    description = "The variable determining a destroy or apply"
    default     = "apply"
}


locals {
  resource_tags = {
    "BU"                      = var.json.tags.BU
    "Environment"             = var.json.tags.Environment
    "DU"                      = var.json.tags.DU
    "SDU"                     = var.json.tags.SDU
    "Product"                 = var.json.tags.Product
    "Cost Center Code"        = var.json.tags.CostCenterCode
    Hierarchy                 = var.json.tags.Hierarchy
    "Industry Specialization" = var.json.tags.IndustrySpecialization
    "Project Code"            = var.json.tags.ProjectCode
    "Project Sponsor"         = var.json.tags.ProjectSponsor
    "Technical Owner"         = var.json.tags.TechnicalOwner
  }
}

data "azurerm_key_vault" "keyvault" {
  name                = var.json.shared_settings.kvname
  resource_group_name = var.json.shared_settings.rg_name
}

data "azurerm_key_vault_secret" "sql_secret" {
  name         = var.json.shared_settings.secret_name
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.json.rg_name
  location = var.json.location
  tags     = local.resource_tags
}

resource "azurerm_storage_account" "sa" {
  name                     = lower("${var.json.storage_account_settings.sql_sa_name}${var.json.environment_name}")
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = var.json.storage_account_settings.account_tier
  account_replication_type = var.json.storage_account_settings.replication_type
  tags                     = local.resource_tags
}
resource "azurerm_storage_container" "container" {
  name                  = var.json.container_settings.sql_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

module "sql_mi" {
  source 	          = "./modules/sql_mi/"
  sqlsecret	          = data.azurerm_key_vault_secret.sql_secret.value
  sqlname		  = var.json.sql_server_settings.login
  resource_group_name     = azurerm_resource_group.resource_group.name
  resource_group_location = azurerm_resource_group.resource_group.location
  environment_name	  = var.json.environment_name
  vnet_name		  = "vnet-${var.json.sql_mi_db.server_name}"
  vnet_address_space	  = var.json.vnet_settings.address_space
  subnet_name		  = "subnet${var.json.sql_mi_db.server_name}"
  nsg_name		  = "${var.json.nsg_settings.name}${var.json.environment_name}"
  sec_name		  = var.json.nsg_settings.sec_name
  rt_name		  = var.json.route_table_settings.name
  rts_address_prefix	  = var.json.route_table_settings.prefix
  rts_next_hop		  = var.json.route_table_settings.hop_type
  resource_tags		  = local.resource_tags
}
  

resource "azurerm_role_assignment" "role_assignment_contributor" {
  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = var.json.role_assignment_contributor.role
  principal_id         = var.json.role_assignment_contributor.principal_id
}

resource "azurerm_role_assignment" "role_assignment_reader" {
  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = var.json.role_assignment_reader.role
  principal_id         = var.json.role_assignment_reader.principal_id
}

