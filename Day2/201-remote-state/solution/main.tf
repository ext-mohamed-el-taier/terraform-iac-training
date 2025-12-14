terraform {
  required_version = ">= 1.14.0, < 1.2"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 4.52.0"
    }
  }
  #backend "azurerm" {
  #  resource_group_name  = "MyTestTerraformState3921"
  #  storage_account_name = "terraformstate3921"
  #  container_name       = "terraform-state-dev"
  #  key                  = "remote-state-lab.tfstate"
  #}
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "MyTestTerraformState3921"
  location = "eastus2"
}
resource "azurerm_storage_account" "main" {
  name                     = "terraformstate3921"
  location                 = "eastus2"
  resource_group_name      = azurerm_resource_group.main.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

#  allow_blob_public_access = true # Only use when configuring Access Key access. NOT PRODUCTION READY!

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "main" {
  name                  = "terraform-state-dev"
  storage_account_name  = azurerm_storage_account.main.name
  #container_access_type = "private" # Use with RBAC
  container_access_type = "container" # Use with Access Key
}

data "azurerm_client_config" "current" {}

# Use RBAC if Owner
#resource "azurerm_role_assignment" "module" {
#  scope                = azurerm_storage_container.main.resource_manager_id
#  principal_id         = data.azurerm_client_config.current.object_id
#  role_definition_name = "Storage Blob Data Owner"
#}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "container_name" {
  value = azurerm_storage_container.main.name
}

output "storage_account_key" {
  value = azurerm_storage_account.main.primary_access_key
}

# Optional - output all backend properties as one object
output "backend_config" {
  value = {
    resource_group_name   = azurerm_resource_group.main.name
    storage_account_name  = azurerm_storage_account.main.name
    container_name        = azurerm_storage_container.main.name
    access_key            = azurerm_storage_account.main.primary_access_key
  }
}
