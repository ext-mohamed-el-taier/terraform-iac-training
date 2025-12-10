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
  }))
  default = {
    web = {
      name_suffix = "web"
      newbits     = 8
      netnum      = 0
    }
    app = {
      name_suffix = "app"
      newbits     = 8
      netnum      = 1
    }
    db = {
      name_suffix = "db"
      newbits     = 8
      netnum      = 2
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

output "vnet" {
  value = module.network.vnet
}

output "subnets" {
  value = module.network.subnets
}

# optional - glob module output together
output "network" {
  value = module.network
}
