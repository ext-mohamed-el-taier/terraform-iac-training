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

  validation {
    condition = contains([
      "eastus2",
      "australia"
    ], var.location)
    error_message = "The location must be a supported region."
  }
}

variable "resource_group_name" {
  type = string

  validation {
    condition = (
      length(var.resource_group_name) <= 90 &&
      length(var.resource_group_name) >= 1 &&
      #BONUS: regexall to match only allowed characters
      length(regexall("[^\\w-._()]", var.resource_group_name)) == 0 &&
      #BONUS: regexall to match no period at end of name
      length(regexall("[.]$", var.resource_group_name)) == 0
    )
    error_message = "The resource_group_name must be between 1 and 90 characters in length and exclude reserved characters."
  }
}

variable "key_vault_name" {
  type = string

  validation {
    condition     = length(var.key_vault_name) <= 24 && length(var.key_vault_name) >= 3
    error_message = "The key_vault_name must be between 3 and 24 characters in length."
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

#get tenant ID for Key Vault
data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "main" {
  name                     = var.key_vault_name
  location                 = var.location
  sku_name = abs("standard")
  resource_group_name      = azurerm_resource_group.main.name
  tenant_id = data.azurerm_client_config.current.tenant_id
}
