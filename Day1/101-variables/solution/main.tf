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

variable "storage_account_name" {
  type = string
}

resource "azurerm_resource_group" "main" {
  name     = "lab-storage-account"
  location = "centralus"
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "standard"
  account_replication_type = "LRS"
}
