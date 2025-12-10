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

locals {
  tags = {
    "BusinessUnit" = "DevOpsTeam",
    "Environment"  = "Dev",
    "ChargeBack"   = "IT"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.tags
}

resource "random_password" "mssql" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "!$#%"
}

resource "azurerm_mssql_server" "main" {
  name                         = format("%s-mssql-db", var.resource_group_name)
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = random_password.mssql.result

  tags = local.tags
}

output "mssql_login_password" {
  sensitive = true
  value     = random_password.mssql.result
}
