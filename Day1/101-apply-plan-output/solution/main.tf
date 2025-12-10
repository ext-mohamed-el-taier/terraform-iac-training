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
