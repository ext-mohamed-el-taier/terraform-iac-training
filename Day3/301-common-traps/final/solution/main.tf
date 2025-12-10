terraform {
  required_version = ">= 0.14.8"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 2.74.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "vnet" {
  description = "An object that defines a simple vNet"
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "SomeVnet1"
    cidr = "10.0.0.0/16"
  }
}

variable "subnets" {
  type = map(object({
    name_suffix = string
    newbits     = number
    netnum      = number
    nsg_rules = map(object({
      port     = string
      priority = number
    }))
  }))
  default = {
    web = {
      name_suffix = "web"
      newbits     = 8
      netnum      = 0
      nsg_rules = {
        http = {
          port     = "80"
          priority = 101
        }
        https = {
          port     = "443"
          priority = 102
        }
      }
    }
    app = {
      name_suffix = "app"
      newbits     = 8
      netnum      = 1
      nsg_rules = {
        tomcat = {
          port     = "8080"
          priority = 100
        }
      }
    }
    db = {
      name_suffix = "db"
      newbits     = 8
      netnum      = 2
      nsg_rules = {
        sql = {
          port     = "1433"
          priority = 100
        }
      }
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source = "./network"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  vnet                = var.vnet
  subnets             = var.subnets
}

module "network_security_rules" {
  source   = "./network_security_rules"
  for_each = var.subnets

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.subnets[each.key].id
  nsg_name_suffix     = each.value.name_suffix
  nsg_rules           = each.value.nsg_rules
}

output "vnet" {
  value = module.network.vnet
}

output "subnets" {
  value = { for k, v in module.network.subnets :
    k => {
      name             = v.name
      vnet             = v.vnet
      id               = v.id
      address_prefixes = v.address_prefixes
      nsg = {
        id    = module.network_security_rules[k].id
        rules = module.network_security_rules[k].rules
      }
    }
  }
}
