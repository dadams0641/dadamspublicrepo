resource "azurerm_virtual_network" "vnet" {
  name          = var.vnet_name
  location      = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space = var.vnet_address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vnet_address_space
  delegation {
    name = "insightsqlmidelegation"
    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = var.sec_name
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_ranges          = ["1433-3343", "11000-11999"]
    destination_port_ranges     = ["1433-3343", "11000-11999"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.resource_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_route_table" "route_table" {
  name                = var.rt_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name                   = var.rt_name
    address_prefix         = var.rts_address_prefix
    next_hop_type          = var.rts_next_hop
  }
  tags = var.resource_tags
}

resource "azurerm_subnet_route_table_association" "rta" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.route_table.id
}

resource "null_resource" "sqlmi" {
provisioner "local-exec" {
    command = "sleep 90; ../..//create_update_sqlMI.py ${var.environment_name} ${var.createdestroy} ${var.sqlname} ${var.sqlsecret}"
  }
}
