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

resource "azurerm_key_vault" "main" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "standard"
  account_replication_type = "LRS"
}
