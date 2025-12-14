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

resource "azurerm_resource_group" "main" {
  name     = "davessweettest1"
  location = "eastus2"
}

resource "azurerm_container_registry" "main" {
  name                = "DavesTestRegistry"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
}
