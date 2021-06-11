/*
This module creates an azure function and an application insights
instance and associates the application insights instance with the
newly created azure function.

A system assigned managed identity will also be enabled for the azure
function and that managed identity will be added to key vault.
*/
locals {
  function_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.ai.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.ai.instrumentation_key};IngestionEndpoint=https://${var.location}-0.in.applicationinsights.azure.com/"
    "MSDEPLOY_RENAME_LOCKED_FILES"          = "1"
    "FUNCTIONS_WORKER_RUNTIME"              = var.worker_runtime
  }
}

# create an application insights instance that will be connected to the azure function
resource "azurerm_application_insights" "ai" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

# azure functions require a storage account
resource "azurerm_storage_account" "storageaccount" {
  account_replication_type = var.storage_account_replication_type
  account_tier             = var.storage_account_tier
  location                 = var.location
  min_tls_version          = "TLS1_2"
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  tags                     = var.tags
}

# create azure function - the app_settings will connect the application insights to this function
resource "azurerm_function_app" "function" {
  app_service_plan_id        = var.app_service_plan_id
  app_settings               = local.function_settings
  https_only                 = var.https_only
  location                   = var.location
  name                       = var.name
  resource_group_name        = var.resource_group_name
  storage_account_access_key = azurerm_storage_account.storageaccount.primary_access_key
  storage_account_name       = azurerm_storage_account.storageaccount.name
  tags                       = var.tags
  version                    = var.runtime_version

  identity {
    type = "SystemAssigned"
  }
}

# add the system-assigned managed identity from the azure function to the key vault
resource "azurerm_key_vault_access_policy" "acess_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_function_app.function.identity.0.tenant_id
  object_id    = azurerm_function_app.function.identity.0.principal_id

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
