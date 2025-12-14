terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 4.52.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}
