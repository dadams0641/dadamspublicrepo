provider "azurerm" {
  version = ">=2.9.0"
  features {}
}

locals {
  northcentralus = "NC"
  resource_tags = {
    "BU"                      = var.json.tags.BU
    "Environment"             = var.json.tags.Environment
    "DU"                      = var.json.tags.DU
    "SDU"                     = var.json.tags.SDU
    "Product"                 = var.json.tags.Product
    "Cost Center Code"        = var.json.tags.CostCenterCode
    "Hierarchy"               = var.json.tags.Hierarchy
    "Industry Specialization" = var.json.tags.IndustrySpecialization
    "Project Code"            = var.json.tags.ProjectCode
    "Project Sponsor"         = var.json.tags.ProjectSponsor
    "Technical Owner"         = var.json.tags.TechnicalOwner
  }

  # tenant application environment location
  tael = "${var.json.tenant}${var.json.application}-${var.json.environment_name}-${local.northcentralus}"

  # short version of tael for resources that require short names
  short_tael = "${substr(var.json.tenant, 0, 3)}${substr(var.json.application, 0, 3)}${substr(var.json.environment_name, 0, 3)}${local.northcentralus}"
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "is_keyvault" {
  name                = var.json.shared_settings.kvname
  resource_group_name = var.json.shared_settings.rg_name
}

data "azurerm_key_vault_secret" "sp_secret" {
  name         = var.json.shared_settings.secret_name
  key_vault_id = data.azurerm_key_vault.is_keyvault.id
}

# resource group
resource "azurerm_resource_group" "resource_group" {
  location = var.json.location
  name     = "${var.json.tenant}${var.json.application}-${var.json.environment_name}1"
  timeouts {
    create = "3h"
    delete = "2h"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# add the contributor role to the resource group
resource "azurerm_role_assignment" "contributor" {
  count                = length(var.json.contributors)
  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = "Contributor"
  principal_id         = var.json.contributors[count.index]
}

# add the reader role to the resource group
resource "azurerm_role_assignment" "reader" {
  count                = length(var.json.readers)
  scope                = azurerm_resource_group.resource_group.id
  role_definition_name = "Reader"
  principal_id         = var.json.readers[count.index]
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

# consumption plan - this is used for azure functions
resource "azurerm_app_service_plan" "consumptionplan" {
  kind                = var.json.consumption_plan_settings.kind
  location            = var.json.location
  name                = "${local.tael}-ConsumptionPlan"
  resource_group_name = azurerm_resource_group.resource_group.name
  tags                = local.resource_tags

  sku {
    size = var.json.consumption_plan_settings.size
    tier = var.json.consumption_plan_settings.tier
  }
}

# app service plan - this is used for traditional app services
resource "azurerm_app_service_plan" "appserviceplan" {
  location            = var.json.location
  name                = "${local.tael}-AppServicePlan"
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    size = var.json.app_service_plan_settings.size
    tier = var.json.app_service_plan_settings.tier
  }
}

# azure active directory app registration for the app services
resource "azuread_application" "app_registration" {
  name                       = "${local.tael}-AppRegistration"
  oauth2_allow_implicit_flow = true
  public_client              = false
  reply_urls                 = ["https://${local.tael}-AppService-Admin.azurewebsites.net","https://${local.tael}-AppService-Admin.azurewebsites.net/.auth/login/aad/callback"]
  type                       = "webapp/api"
  required_resource_access {
    resource_app_id = "00000003-0000-0ff1-ce00-000000000000" # sharepoint
    resource_access {
      id   = "56680e0d-d2a3-4ae1-80d8-3c4f2100e3d0" # allsites.fullcontrol
      type = "Scope"
    }
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # microsoft.graph
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1" #email
      type = "Scope"
    }
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" #offlineaccess
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" #openid
      type = "Scope"
    }
    resource_access {
      id   = "b340eb25-3456-403f-be2f-af7a0d370277" #profile
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" #user.read
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" #user.readbasic.all
      type = "Scope"
    }
  }

}

# service principal attached to the app registration above
resource "azuread_service_principal" "service_principal" {
  application_id               = azuread_application.app_registration.application_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "insight_app_client_secret" {
  application_object_id = azuread_application.app_registration.id
  description          = "InsightApp"
  value                = data.azurerm_key_vault_secret.sp_secret.value
  end_date             = "2099-01-01T00:00:00Z"
}

# add the service principal for the app registration to the key vault
resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.service_principal.object_id

  secret_permissions = [
    "get",
    "list",
    "set"
  ]
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

# azure functions
module "functions" {
  count  = length(var.json.functions)
  source = "./modules/azure_function_with_ai"

  app_service_plan_id              = azurerm_app_service_plan.consumptionplan.id
  application_insights_name        = "${local.tael}-ApplicationInsights-${var.json.functions[count.index].name}"
  https_only                       = true
  key_vault_id                     = azurerm_key_vault.keyvault.id # give the app service a key vault so that the managed identity created on the app service can be added to the key vault
  location                         = var.json.location
  name                             = "${local.tael}-FunctionApp-${var.json.functions[count.index].name}"
  resource_group_name              = azurerm_resource_group.resource_group.name
  runtime_version                  = var.json.function_settings.version
  storage_account_name             = lower("${local.short_tael}${substr(var.json.functions[count.index].name, 0, 3)}sa")
  storage_account_replication_type = var.json.function_settings.storage_account_settings.replication_type
  storage_account_tier             = var.json.function_settings.storage_account_settings.tier
  worker_runtime                   = var.json.functions[count.index].worker_runtime
  tags                             = local.resource_tags
}

# web apps
module "appservices" {
  count  = length(var.json.app_services)
  source = "./modules/app_service_with_ai"

  app_registration_client_id = azuread_application.app_registration.application_id # give the app service an app registration so that active directory auth can be configured in the app service
  app_service_plan_id        = azurerm_app_service_plan.appserviceplan.id
  application_insights_name  = "${local.tael}-ApplicationInsights-${var.json.app_services[count.index].name}"
  auth_enabled               = var.json.app_services[count.index].auth_enabled
  https_only                 = true
  key_vault_id               = azurerm_key_vault.keyvault.id # give the app service a key vault so that the managed identity created on the app service can be added to the key vault
  location                   = var.json.location
  name                       = "${local.tael}-AppService-${var.json.app_services[count.index].name}"
  resource_group_name        = azurerm_resource_group.resource_group.name
  tags                       = local.resource_tags
}

resource "azurerm_data_factory" "data_factory" {
  name                = "${var.json.data_factory_settings.name}-${var.json.environment_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  tags                = var.json.tags
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

# add limited access to the key vault to additional groups and principals
resource "azurerm_key_vault_access_policy" "keyvault_limited_access_users" {
  count        = length(var.json.keyvault_limited_access_ids)
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.json.keyvault_limited_access_ids[count.index].object_id
  secret_permissions = [
    "get",
    "list",
    "set"
  ]
}

# apply service principal secret to insight next KV
resource "azurerm_key_vault_secret" "sp_secret_entry" {
  name         = var.json.shared_settings.new_secret_name
  value        = data.azurerm_key_vault_secret.sp_secret.value
  key_vault_id = azurerm_key_vault.keyvault.id
}

# redis cache
resource "azurerm_redis_cache" "redis" {
  name                = "${var.json.redis_settings.name}-${var.json.environment_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  capacity            = var.json.redis_settings.capacity
  family              = var.json.redis_settings.family
  sku_name            = var.json.redis_settings.sku
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  tags                = local.resource_tags

  redis_configuration {
    enable_authentication = true
  }
}

# log analytics
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${var.json.log_analytics_settings.name}-${var.json.environment_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# api management
resource "azurerm_api_management" "api_management" {
  name                = "${var.json.apim_settings.name}-${var.json.environment_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  publisher_name      = "Crowe LLP"
  publisher_email     = "Zach.Schultz@crowe.com"
  tags                = local.resource_tags

  sku_name = "Developer_1"

  policy {
    xml_content = <<XML
    <policies>
      <inbound />
      <backend />
      <outbound />
      <on-error />
    </policies>
XML

  }
}

# application insights for api management resource
resource "azurerm_application_insights" "apim_app_insights" {
  name                = var.json.application_insights.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

# logger for api management resource
resource "azurerm_api_management_logger" "apim_logger" {
  name                = "${var.json.apim_settings.logger_name}-${var.json.environment_name}"
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name

  application_insights {
    instrumentation_key = azurerm_application_insights.apim_app_insights.instrumentation_key
  }
}

# azure service bus
resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                = "${var.json.servicebus_settings.name}-${var.json.environment_name}"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = var.json.servicebus_settings.sku
  capacity            = var.json.servicebus_settings.capacity
  tags                = local.resource_tags
}

# signal r
resource "azurerm_signalr_service" "signalr" {
  name                = "${local.tael}-SignalR"
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.resource_group.name
  sku {
    name     = "Standard_S1"
    capacity = 1
  }
  cors {
    allowed_origins = ["*"]
  }
  features {
    flag  = "ServiceMode"
    value = "Serverless"
  }
}

resource "azurerm_role_assignment" "app_service" {
  count                = length(var.json.app_services)
  scope                = azurerm_servicebus_namespace.sb_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.appservices[count.index].principalid
}

resource "azurerm_role_assignment" "function_app_service" {
  count                = length(var.json.functions)
  scope                = azurerm_servicebus_namespace.sb_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.functions[count.index].principalid
}
