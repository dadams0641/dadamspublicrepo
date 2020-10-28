provider "azurerm" {
  version = ">=2.9.0"
  features {}
}

locals {
  resource_tags = {
    "Environment"             = var.json.tags.Environment
    "Product"                 = var.json.tags.Product
    "Technical Owner"         = var.json.tags.TechnicalOwner
  }

  tael = "${var.json.application}-${var.json.environment_name}"

  short_tael = "${substr(var.json.application, 0, 3)}${substr(var.json.environment_name, 0, 3)}"
}

data "azurerm_client_config" "current" {}

/*
This section would be used to pull passwords from Keyvault to avoid PT sensitive data in the TFPlan/State
data "azurerm_key_vault" "is_keyvault" {
  name                = var.json.shared_settings.kvname
  resource_group_name = var.json.shared_settings.rg_name
}

data "azurerm_key_vault_secret" "sp_secret" {
  name         = var.json.shared_settings.secret_name
  key_vault_id = data.azurerm_key_vault.is_keyvault.id
}
*/

# resource group
resource "azurerm_resource_group" "resource_group" {
  location = var.json.location
  name     = "${var.json.application}-${var.json.environment_name}1"
  timeouts {
    create = "3h"
    delete = "2h"
  }
}

# add the roles to the resource group
resource "azurerm_role_assignment" "role_assignment" {
  count                = length(var.json.role_assignment)
  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = var.json.role_assignment[count.index].role
  principal_id         = var.json.role_assignment[count.index].principal_id
}

# key vault
resource "azurerm_key_vault" "keyvault" {
  name                        = lower("${local.short_tael}kv")
  location                    = azurerm_resource_group.resource_group.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = local.resource_tags
}

# app service plan - this is used for traditional app services
resource "azurerm_app_service_plan" "appserviceplan" {
  location            = var.json.location
  name                = "${local.tael}-AppServicePlan"
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = var.json.app_service_plan_settings.kind
  reserved            = true

  sku {
    size = var.json.app_service_plan_settings.size
    tier = var.json.app_service_plan_settings.tier
  }
}

# auto-scale plan for the app serivces
resource "azurerm_monitor_autoscale_setting" "appserviceplan_autoscale" {
  name                = "${var.json.application}AutoScaleSetting"
  location            = var.json.location
  resource_group_name = azurerm_resource_group.resource_group.name
  target_resource_id  = azurerm_app_service_plan.appserviceplan.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = var.json.app_service_plan_settings.scale_settings.capacity.minimum
      maximum = var.json.app_service_plan_settings.scale_settings.capacity.maximum
    }

    rule {
      metric_trigger {
        metric_name        = "CPUPercentage"
        metric_resource_id = azurerm_app_service_plan.appserviceplan.id
        time_grain         = "PT${var.json.app_service_plan_settings.scale_settings.cpu_metric.time_grain}M"
        statistic          = "Average"
        time_window        = "PT${var.json.app_service_plan_settings.scale_settings.cpu_metric.time_window}M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.json.app_service_plan_settings.scale_settings.cpu_metric.scale_up_percent_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = var.json.app_service_plan_settings.scale_settings.cpu_metric.scale_up_count
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CPUPercentage"
        metric_resource_id = azurerm_app_service_plan.appserviceplan.id
        time_grain         = "PT${var.json.app_service_plan_settings.scale_settings.cpu_metric.time_grain}M"
        statistic          = "Average"
        time_window        = "PT${var.json.app_service_plan_settings.scale_settings.cpu_metric.time_window}M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.json.app_service_plan_settings.scale_settings.cpu_metric.scale_down_percent_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = var.json.app_service_plan_settings.scale_settings.cpu_metric.scale_down_count
        cooldown  = "PT1M"
      }
    }
  }
}

# add full access to the key vault to cloud engineers
resource "azurerm_key_vault_access_policy" "keyvault_full_access_users" {
  count        = length(var.json.keyvault_full_access_ids)
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.json.keyvault_full_access_ids[count.index].object_id
  key_permissions = [
    "get",
    "import",
    "list",
    "recover",
    "restore",
    "backup",
    "create",
    "delete"
  ]

  secret_permissions = [
    "backup",
    "delete",
    "get",
    "list",
    "recover",
    "restore",
    "set"
  ]

  storage_permissions = [
    "backup",
    "delete",
    "deletesas",
    "get",
    "getsas",
    "list",
    "listsas",
    "purge",
    "recover",
    "regeneratekey",
    "restore",
    "set",
    "setsas",
    "update"
  ]
}