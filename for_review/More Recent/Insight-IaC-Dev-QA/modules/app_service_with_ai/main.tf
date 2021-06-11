/*
This module creates an app service and an application insights
instance and associates the application insights instance with the
newly created app service.

A system assigned managed identity will also be enabled for the app
service and that managed identity will be added to key vault.
*/
locals {
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.ai.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = "InstrumentationKey=${azurerm_application_insights.ai.instrumentation_key}"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
    "XDT_MicrosoftApplicationInsights_Mode"      = "default"
    "MSDEPLOY_RENAME_LOCKED_FILES"               = "1"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_application_insights" "ai" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

resource "azurerm_app_service" "appservice" {
  app_service_plan_id = var.app_service_plan_id
  app_settings        = local.app_settings
  https_only          = var.https_only
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  auth_settings {
    enabled                       = var.auth_enabled
    issuer                        = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}"
    default_provider              = "AzureActiveDirectory"
    unauthenticated_client_action = "RedirectToLoginPage"

    active_directory {
      client_id = var.app_registration_client_id
    }
  }

    site_config {
    cors {
      allowed_origins = ["*"]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings
    ]
  }

  timeouts {
    create = "3h"
    delete = "2h"
  }
}

resource "azurerm_key_vault_access_policy" "acess_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_app_service.appservice.identity.0.tenant_id
  object_id    = azurerm_app_service.appservice.identity.0.principal_id

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