data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "primary" {
}

data "azurerm_key_vault_secret" "k8s_admin_client_certificate_aks" {
  name         = var.aks_clusters.eastus2.k8s_admin_client_certificate_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "k8s_admin_client_key_aks" {
  name         = var.aks_clusters.eastus2.k8s_admin_client_key_secret_name
  key_vault_id = var.key_vault_id
}
data "azurerm_key_vault_secret" "k8s_admin_cluster_ca_certificate_aks" {
  name         = var.aks_clusters.eastus2.k8s_admin_cluster_ca_certificate_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "k8s_admin_client_certificate_aks_paired" {
  name         = var.aks_clusters.centralus.k8s_admin_client_certificate_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "k8s_admin_client_key_aks_paired" {
  name         = var.aks_clusters.centralus.k8s_admin_client_key_secret_name
  key_vault_id = var.key_vault_id
}
data "azurerm_key_vault_secret" "k8s_admin_cluster_ca_certificate_aks_paired" {
  name         = var.aks_clusters.centralus.k8s_admin_cluster_ca_certificate_secret_name
  key_vault_id = var.key_vault_id
}

## BEGIN: Istio Cert Lookups 
data "azurerm_key_vault" "limited" {
  name                = var.common_certificates_limited_keyvault_name
  resource_group_name = var.common_certificates_limited_keyvault_resource_group_name
}

data "azurerm_key_vault_secret" "citadel_intermediate_ca_key_secret_name" {
  name         = var.citadel_intermediate_ca_key_secret_name
  key_vault_id = data.azurerm_key_vault.limited.id
}

data "azurerm_key_vault_secret" "citadel_intermediate_ca_cert_secret_name" {
  name         = var.citadel_intermediate_ca_cert_secret_name
  key_vault_id = data.azurerm_key_vault.limited.id
}

## END: Istio Cert Lookups 

module "k8s-config-eastus2" {
  source                         = "./modules/k8s_config"
  realm                          = var.realm
  environment                    = var.cluster_id
  location                       = "eastus2"
  dps_intermediate_keyvault_name = var.dps_intermediate_keyvault_name
  cluster_fqdn                   = var.aks_clusters.eastus2.fqdn
  aks_id                         = var.aks_clusters.eastus2.aks_id
  environment_keyvault_id        = var.key_vault_id
  products_from_base             = var.platform_product_security_config
  products                       = var.products
  ca-key                         = data.azurerm_key_vault_secret.citadel_intermediate_ca_key_secret_name.value
  ca-cert                        = data.azurerm_key_vault_secret.citadel_intermediate_ca_cert_secret_name.value
}

module "k8s-config-centralus" {
  source = "./modules/k8s_config"
  providers = {
    kubernetes = kubernetes.centralus
  }
  realm                          = var.realm
  environment                    = var.cluster_id
  location                       = "centralus"
  dps_intermediate_keyvault_name = var.dps_intermediate_keyvault_name
  cluster_fqdn                   = var.aks_clusters.centralus.fqdn
  aks_id                         = var.aks_clusters.centralus.aks_id
  environment_keyvault_id        = var.key_vault_id
  products_from_base             = var.platform_product_security_config
  products                       = var.products
  ca-key                         = data.azurerm_key_vault_secret.citadel_intermediate_ca_key_secret_name.value
  ca-cert                        = data.azurerm_key_vault_secret.citadel_intermediate_ca_cert_secret_name.value
}

