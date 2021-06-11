resource "azurerm_role_assignment" "role_assignment" {
  scope                = var.resource_group_id
  role_definition_name = var.role_name
  principal_id         = var.principalid
}
