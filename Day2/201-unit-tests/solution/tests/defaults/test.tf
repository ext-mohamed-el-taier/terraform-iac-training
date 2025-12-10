terraform {
  required_version = "= 0.14.8"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "= 2.89.0"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "= 3.0.0"
    }
    time = {
      source  = "registry.terraform.io/hashicorp/time"
      version = "= 0.7.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "eastus2"
  tags = {
    billing     = "test@test.test"
    environment = "test"
  }
}

resource "azurerm_resource_group" "test" {
  name     = "storage-test-basic"
  location = local.location
}

resource "random_integer" "test" {
  min = 1
  max = 99999
  keepers = {
    resource_name_prefix = azurerm_resource_group.test.name
  }
}

module "terraform-state" {
  source               = "../../"
  resource_group_name  = azurerm_resource_group.test.name
  location             = local.location
  storage_account_name = format("%s%s", "satestbasic", random_integer.test.result)

  depends_on = [
    azurerm_resource_group.test
  ]

  tags = local.tags
}
