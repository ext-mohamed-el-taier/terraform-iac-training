variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "nsg_name_suffix" {
  type = string
}

variable "nsg_rules" {
  type = map(object({
    port     = string
    priority = number
  }))
}

resource "azurerm_network_security_group" "allow_inbound" {
  name                = format("InboundFromInternetTo%s", var.nsg_name_suffix)
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_inbound" {
  for_each = var.nsg_rules

  name                        = format("allowInbound%s", each.value.port)
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.port
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.allow_inbound.name
}

resource "azurerm_subnet_network_security_group_association" "allow_inbound" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.allow_inbound.id
}

output "id" {
  value = azurerm_network_security_group.allow_inbound.id
}

output "rules" {
  value = azurerm_network_security_group.allow_inbound.security_rule
}
