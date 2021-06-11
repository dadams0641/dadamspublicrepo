variable "app_service_plan_id" {
  type        = string
  description = "The unique identifier for the app service plan that the app service runs under"
}

variable "application_insights_name" {
  type        = string
  description = "The name of the application insights tied to the app service"
}

variable "app_registration_client_id" {
  type        = string
  description = "The unique identifier for an active directory app registration so the app service can use aad for authentication"
}

variable "auth_enabled" {
  type        = bool
  description = "Whether or not to enable app service authentication"
}

variable "https_only" {
  type        = bool
  description = "Whether to allow only HTTPS traffic"
}

variable "key_vault_id" {
  type        = string
  description = "The unique identifier for a key vault where the managed identity for this app service can be added to the access policies"
}

variable "location" {
  type        = string
  description = "The Azure region where the app service will be deployed"
}

variable "name" {
  type        = string
  description = "The name of the app service"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that the app service is deployed in"
}

variable "tags" {
  type        = map(string)
  description = "String values used to organize resources"
}
