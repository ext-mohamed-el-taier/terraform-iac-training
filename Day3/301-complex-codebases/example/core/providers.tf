terraform {
  backend "azurerm" {
  }
  required_version = "~> 0.12.24"
}

provider "azurerm" {
  version                    = "2.8"
  skip_provider_registration = true
  features {}
}

provider "azuread" {
  version = "0.7.0"
}

provider "random" {
  version = "2.2.0"
}

provider "kubernetes" {
  version                = "~> 1.11.1"
  host                   = lookup(var.aks_clusters, "eastus2").k8s_host
  client_certificate     = base64decode(data.azurerm_key_vault_secret.k8s_admin_client_certificate_aks.value)
  client_key             = base64decode(data.azurerm_key_vault_secret.k8s_admin_client_key_aks.value)
  cluster_ca_certificate = base64decode(data.azurerm_key_vault_secret.k8s_admin_cluster_ca_certificate_aks.value)
  load_config_file       = false
}

provider "kubernetes" {
  alias                  = "centralus"
  version                = "~> 1.11.1"
  host                   = lookup(var.aks_clusters, "centralus").k8s_host
  client_certificate     = base64decode(data.azurerm_key_vault_secret.k8s_admin_client_certificate_aks_paired.value)
  client_key             = base64decode(data.azurerm_key_vault_secret.k8s_admin_client_key_aks_paired.value)
  cluster_ca_certificate = base64decode(data.azurerm_key_vault_secret.k8s_admin_cluster_ca_certificate_aks_paired.value)
  load_config_file       = false
}

provider "azurerm" {
  alias                      = "Legacy"
  subscription_id            = "xxxx"
  version                    = "2.8"
  skip_provider_registration = true
  features {}
}

