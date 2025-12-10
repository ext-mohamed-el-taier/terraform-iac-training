terraform {
  required_version = ">= 0.14.8"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 2.74.0"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "> 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type = string
}

variable "db_name" {
  type = string
}

resource "random_password" "sql" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "!$#%"
}

module "database" {
  source  = "Azure/database/azurerm"
  version = "1.1.0"

  db_name            = var.db_name
  location           = var.location
  sql_admin_username = "SQLBoss"
  sql_password       = random_password.sql.result
}


