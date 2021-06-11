variable "app_service_plan_id" {
  type        = string
  description = "The unique identifier for the app service plan that the function runs under"
}

variable "application_insights_name" {
  type        = string
  description = "The name of the application insights tied to the function"
}

variable "https_only" {
  type        = bool
  description = "Whether to allow only HTTPS traffic"
}

variable "key_vault_id" {
  type        = string
  description = "The unique identifier for a key vault where the managed identity for this function can be added to the access policies"
}

variable "location" {
  type        = string
  description = "The Azure region where the function will be deployed"
}

variable "name" {
  type        = string
  description = "The name of the function"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that the function is deployed in"
}

variable "runtime_version" {
  type        = string
  description = "The runtime version associated with the function app"
}

variable "storage_account_name" {
  type        = string
  description = "The backend storage account name which will be used by this function app"
}

variable "storage_account_replication_type" {
  type        = string
  description = "The type of replication for the storage account"
}

variable "storage_account_tier" {
  type        = string
  description = "The pricing tier for the storage account"
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources"
}

variable "worker_runtime" {
  type        = string
  description = "Declaration of the worker runtime type. [powershell], [dotnet], etc."
}
