variable "location" {
  default = "eastus2"
}

variable "realm" {
  default = "nonprod"
}

variable "cluster_id" {
  description = "cluster_id is used in the all of the items that can create name clashes between independent clusters.  User clusters should use their lowercase initials.  xxxx production clusters will be prefixed with 'sr'."
}

variable "vm_username" {
  description = "The username of the first account on the provisioned VMs."
  default     = "azureuser"
}

variable "rg_name_cloud_components" {
  default = "xxxx_nomad_servers"
}

variable "rg_name_xxxx_units" {
  default = "xxxx_compute_cluster"
}

# AKS stuff

variable "dps_intermediate_keyvault_name" {
}

# General stuff
variable "tags" {
  type = map(string)

  default = {
    repo = "tf_xxxx_cloud_compute"
  }
}

variable "data_backend_resource_group_name_xxxx_init" {
  default = "TerraformBackend"
}

variable "data_backend_storage_account_xxxx_init" {
  default = "xxxxterraformbackend"
}

variable "data_backend_container_xxxx_init" {
  default = "tfstate"
}

variable "products" {
  description = "Map of product configuration to configure compute for" #Review schema here: https://xxxx-rd.visualstudio.com/Platform/_git/product?path=%2FREADME.md&_a=preview
}

variable "platform_product_security_config" {
  description = "Legacy product configuration to be replaced fully by the products variable"
}

variable "aks_clusters" {
  description = "Map of custers that need compute configured"
}
variable "key_vault_id" {
  description = "Platform keyvault id"
}

variable "common_certificates_limited_keyvault_name" {
  description = "Limited Key Vault name"
}

variable "common_certificates_limited_keyvault_resource_group_name" {
  description = "Limted Key Vault resource group name"
}

variable "citadel_intermediate_ca_key_secret_name" {
  description = "Istio Intermediate CA key secret name"
}

variable "citadel_intermediate_ca_cert_secret_name" {
  description = "Istio Intermedia CA cert secret name"
}
