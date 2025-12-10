variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet" {
  description = "An object that defines a simple vNet"
  type = object({
    name = string
    cidr = string
  })
}

variable "subnets" {
  type = map(object({
    name_suffix = string
    newbits     = number
    netnum      = number
  }))
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet.cidr]
}

resource "azurerm_subnet" "main" {
  for_each = var.subnets

  name                 = format("%s-%s", var.vnet.name, each.value.name_suffix)
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.vnet.cidr, each.value.newbits, each.value.netnum)]
}

resource "azurerm_network_security_group" "allow_inbound" {
  name                = "InboundFromInternet"
  location            = var.location
  resource_group_name = var.resource_group_name
}

locals {
  inbound_allow_ports = ["22", "80", "443"]
}

resource "azurerm_network_security_rule" "allow_inbound" {
  count = length(local.inbound_allow_ports)

  name                        = format("allowInbound%s", local.inbound_allow_ports[count.index])
  priority                    = (100 + count.index)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = local.inbound_allow_ports[count.index]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.allow_inbound.name
}

resource "azurerm_subnet_network_security_group_association" "allow_inbound" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.main[each.key].id
  network_security_group_id = azurerm_network_security_group.allow_inbound.id
}

output "vnet" {
  value = {
    name          = azurerm_virtual_network.main.name
    address_space = azurerm_virtual_network.main.address_space
  }
}

output "subnets" {
  value = { for k, v in azurerm_subnet.main :
    k => {
      name             = v.name
      vnet             = v.virtual_network_name
      id               = v.id
      address_prefixes = v.address_prefixes
    }
  }
}
