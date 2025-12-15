terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

# =============================================================================
# VARIABLES FOR SUBSCRIPTION IDs
# =============================================================================

variable "subscription_id_primary" {
  type        = string
  description = "Subscription ID for the primary subscription (vm_list)"
}

variable "subscription_id_secondary" {
  type        = string
  description = "Subscription ID for the secondary subscription (vm_list2)"
}

# =============================================================================
# MULTIPLE PROVIDER CONFIGURATIONS
# =============================================================================

# Primary provider - default provider for vm_list
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id_primary
}

# Secondary provider with alias - for vm_list2 in different subscription
provider "azurerm" {
  alias           = "secondary"
  features {}
  subscription_id = var.subscription_id_secondary
}

# =============================================================================
# VM LISTS FOR EACH SUBSCRIPTION
# =============================================================================

variable "vm_list" {
  type = map(object({
    name = string
    zone = string
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
  description = "Map of VMs to deploy in the PRIMARY subscription"
}

variable "vm_list2" {
  type = map(object({
    name = string
    zone = string
  }))
  default = {
    "db" = {
      name = "dbserver"
      zone = "1"
    }
    "cache" = {
      name = "cacheserver"
      zone = "2"
    }
  }
  description = "Map of VMs to deploy in the SECONDARY subscription"
}

variable "prefix" {
  default = "tstraub-live"
}

variable "location" {
  default = "eastus"
}

# =============================================================================
# PRIMARY SUBSCRIPTION RESOURCES (using default provider)
# =============================================================================

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

# =============================================================================
# SECONDARY SUBSCRIPTION RESOURCES (using provider alias)
# =============================================================================

resource "azurerm_resource_group" "secondary" {
  provider = azurerm.secondary

  name     = "${var.prefix}-secondary-rg"
  location = var.location
}

resource "azurerm_virtual_network" "secondary" {
  provider = azurerm.secondary

  name                = "${var.prefix}-secondary-vnet"
  address_space       = ["10.1.0.0/24"]
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
}

resource "azurerm_subnet" "secondary" {
  provider = azurerm.secondary

  name                 = "${var.prefix}-secondary-subnet"
  resource_group_name  = azurerm_resource_group.secondary.name
  virtual_network_name = azurerm_virtual_network.secondary.name
  address_prefixes     = ["10.1.0.128/25"]
}

resource "azurerm_public_ip" "secondary" {
  for_each = var.vm_list2
  provider = azurerm.secondary

  name                = "${var.prefix}-secondary-pubip-${each.key}"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.value.zone]
}

resource "azurerm_network_interface" "secondary" {
  for_each = var.vm_list2
  provider = azurerm.secondary

  name                = "${var.prefix}-secondary-nic-${each.key}"
  location            = azurerm_resource_group.secondary.location
  resource_group_name = azurerm_resource_group.secondary.name

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.secondary.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.secondary[each.key].id
  }
}

resource "azurerm_linux_virtual_machine" "secondary" {
  for_each = var.vm_list2
  provider = azurerm.secondary

  name                            = "${var.prefix}-${each.value.name}"
  location                        = azurerm_resource_group.secondary.location
  resource_group_name             = azurerm_resource_group.secondary.name
  size                            = "Standard_A2_v2"
  zone                            = each.value.zone
  admin_username                  = "testadmin"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.secondary[each.key].id]

  os_disk {
    name                 = "${var.prefix}-secondary-${each.key}-osdisk"
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

# =============================================================================
# OUTPUTS
# =============================================================================

# Primary subscription outputs
output "primary-private-ip" {
  value       = { for k, v in azurerm_network_interface.main : k => v.private_ip_address }
  description = "Private IP Addresses in Primary Subscription"
}

output "primary-public-ip" {
  value       = { for k, v in azurerm_public_ip.main : k => v.ip_address }
  description = "Public IP Addresses in Primary Subscription"
}

# Secondary subscription outputs
output "secondary-private-ip" {
  value       = { for k, v in azurerm_network_interface.secondary : k => v.private_ip_address }
  description = "Private IP Addresses in Secondary Subscription"
}

output "secondary-public-ip" {
  value       = { for k, v in azurerm_public_ip.secondary : k => v.ip_address }
  description = "Public IP Addresses in Secondary Subscription"
}
