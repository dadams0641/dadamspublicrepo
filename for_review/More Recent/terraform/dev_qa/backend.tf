terraform {
  backend "azurerm" {
    resource_group_name  = "IS_Shared_DEV"
    storage_account_name = "isbackenddev"
    container_name       = "tfbackend"
      }
}


