output "tenantid" {
  value       = azurerm_function_app.function.identity[0].tenant_id
  description = "Tenant ID for the App Service Managed Identity"
  sensitive   = false
}

output "principalid" {
  value       = azurerm_function_app.function.identity[0].principal_id
  description = "Principal ID for the App Service Managed Identity"
  sensitive   = false
}
