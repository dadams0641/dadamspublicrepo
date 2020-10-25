variable "json" {
  type        = any
  description = "JSON containing all TF Vars"
}

variable "createdestroy" {
    type        = string
    description = "The variable determining a destroy or apply"
    default     = "apply"
}

variable "sqlsecret" {
    type	= string
    description = "Secret Value for SQL MI"
}

variable "sqlname" {
    type        = string
    description = "Name SQL Managed Instance"
}
variable "resource_group_name" {
    type        = string
    description = "Name of the Resource Group"
}
variable "resource_group_location" {
    type        = string
    description = "Location of the Resource Group"
}
variable "environment_name" {
    type        = string
    description = "Environment being deployed to"
}
variable "vnet_name" {
    type        = string
    description = "Name of the Virtual Network"
}
variable "vnet_address_space" {
    type        = string
    description = "Address Space for the Virtual Network to utilize"
}
variable "subnet_name" {
    type        = string
    description = "Name of the Subnet"
}
variable "nsg_name" {
    type        = string
    description = "Name of the Network Security Group"
}
variable "sec_name" {
    type        = string
    description = "Name of the Network Security Rule"
}
variable "rt_name" {
    type        = string
    description = "Name of the Route Table"
}
variable "rts_address_prefix" {
    type        = string
    description = "Route Table Address Prefix"
}
variable "rts_next_hop" {
    type        = string
    description = "Value specifying the next hop in the Route Table"
}
variable "resource_tags" {
    type	= map(string)
    description = "Resource Tags for Taggble Resources in Azure"
}
