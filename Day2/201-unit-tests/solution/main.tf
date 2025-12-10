terraform {
  required_version = ">= 0.14.8"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = ">= 2.74.0"
    }
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_account_tier" {
  description = "The storage account tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The storage account tier must be a supported type. See https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview?toc=/azure/storage/blobs/toc.json."
  }
}

variable "storage_replication_type" {
  description = "The storage account replication type for bootstrap storage"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RA-GRS", "GZRS", "RA-GZRS"], var.storage_replication_type)
    error_message = "The replication type must be a supported type. See https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy."
  }
}

variable "storage_delete_retention_in_days" {
  description = "The storage account delete retention policy in days"
  type        = number
  default     = 7

  validation {
    condition     = var.storage_delete_retention_in_days <= 365 && var.storage_delete_retention_in_days > 1
    error_message = "The retention policy (in days) must be between 1 and 365 days."
  }
}

variable "tags" {
  description = "A map of tags to apply to all supporting resources in this module"
  type        = map(string)
  default     = {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "module" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  account_kind             = "StorageV2"

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.storage_delete_retention_in_days
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

}
