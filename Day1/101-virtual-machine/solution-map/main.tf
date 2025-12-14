terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "vm_list" {
  type = map(object({
    name  = string
    zone  = string
  }))
  default = {
    "web" = {
      name = "webserver"
      zone = "1"
    }
    "app" = {
      name = "appserver"
      zone = "2"
    }
  }
  description = "Map of VMs with their unique attributes"
}

variable "prefix" {
  default = "tstraub-live"
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.128/25"]
}

resource "azurerm_public_ip" "main" {
  for_each = var.vm_list

  name                = "${var.prefix}-pubip-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value.zone]
}

resource "azurerm_network_interface" "main" {
  for_each = var.vm_list

  name                = "${var.prefix}-nic-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = var.vm_list

  name                            = "${var.prefix}-${each.value.name}"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_A2_v2"
  zone                            = each.value.zone
  admin_username                  = "testadmin"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.main[each.key].id]

  os_disk {
    name                 = "${var.prefix}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "private-ip" {
  value       = { for k, v in azurerm_network_interface.main : k => v.private_ip_address }
  description = "Private IP Address"
}

output "public-ip" {
  value       = { for k, v in azurerm_public_ip.main : k => v.ip_address }
  description = "Public IP Address"
}
