variable "cluster_fqdn" {

}
variable "aks_id" {

}
variable "environment_keyvault_id" {
  description = "Key vault id to store any cluster specific tokens"
}

variable "realm" {
  description = "Applicable realm for naming conventions and auth groups (prod|nonprod)"
}

variable "environment" {
  description = "Applicable environment for naming conventions of resources"
}

variable "location" {
  description = "Applicable location for naming conventions of resources (eastus2|centralus)"
}

variable "dps_intermediate_keyvault_name" {
  description = "Key vault for environment that stores DPS certificate information"
}

variable "products_from_base" {
  description = "product object [see security model](https://xxxx-rd.visualstudio.com/Platform/_wiki/wikis/xxxx%20xxxx%20Security/1383/Security-Model)"
}
variable "products" {
  description = "product object [see security model](https://xxxx-rd.visualstudio.com/Platform/_wiki/wikis/xxxx%20xxxx%20Security/1383/Security-Model)"
}

variable "ca-key" {
  description = "CA Cert Key"
}

variable "ca-cert" {
  description = "CA Cert"
}

variable "ca-root" {
  default     = null
  description = "CA Root Cert"
}

variable "ca-chain" {
  default     = null
  description = "CA Chain"
}
