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
