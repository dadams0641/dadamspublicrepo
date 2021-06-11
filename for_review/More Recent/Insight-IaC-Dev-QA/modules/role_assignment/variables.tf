variable "resource_group_id" {
  type        = string
  description = "Resource Group ID Used for Scoping the Roles"
}

variable "role_name" {
  type        = string
  description = "Name of the Role to be Applied to the Principal ID"
}

variable "principalid" {
  description = "The Principal ID In Which to Apply the Role"
}
