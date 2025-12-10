# AKS - KeyVault Flexvol integration
locals {
  sp_suffix = "${var.location}-xxxx-kv-read"
}

resource "azuread_application" "xxxx-kv-read-app" {
  name                       = "${var.cluster_id}-${local.sp_suffix}"
  homepage                   = "https://${var.cluster_id}-${local.sp_suffix}"
  identifier_uris            = ["https://${var.cluster_id}-${local.sp_suffix}"]
  reply_urls                 = ["https://${var.cluster_id}-${local.sp_suffix}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "xxxx-kv-read-sp" {
  application_id = azuread_application.xxxx-kv-read-app.application_id
}

resource "random_string" "xxxx-kv-read-random" {
  length  = 32
  special = false

  keepers = {
    aks_cluster = "${var.aks_cluster_id}"
  }
}

resource "azuread_service_principal_password" "xxxx-kv-read-sp-pw" {
  service_principal_id = azuread_service_principal.xxxx-kv-read-sp.id
  value                = random_string.xxxx-kv-read-random.result
  end_date             = "2029-01-03T01:02:00Z"
}

resource "azurerm_key_vault_secret" "xxxx-kv-read-sp-pw" {
  name         = "xxxx-kv-reader-sp-${var.location}"
  value        = azuread_service_principal_password.xxxx-kv-read-sp-pw.value
  key_vault_id = var.keyvault_id
  content_type = "autogen-password"
}

resource "azurerm_role_assignment" "kv-read" {
  scope                = var.keyvault_id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.xxxx-kv-read-sp.id
}

resource "azurerm_key_vault_access_policy" "kv-get-only" {
  key_vault_id = var.keyvault_id

  tenant_id = var.tenant_id
  object_id = azuread_service_principal.xxxx-kv-read-sp.id

  key_permissions         = ["get"]
  secret_permissions      = ["get"]
  certificate_permissions = ["get"]
}

# Add KeyVault FlexVol ID to the keyvault which holds the DPS certs for the env
data "azurerm_key_vault" "dps_cert" {
  name                = var.dps_cert_keyvault
  resource_group_name = (var.realm == "prod" ? "common-certificates-prod" : "common-certificates-nonprod")
}

resource "azurerm_role_assignment" "kv-read-dps" {
  scope                = data.azurerm_key_vault.dps_cert.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.xxxx-kv-read-sp.id
}

resource "azurerm_key_vault_access_policy" "dps_cert" {
  key_vault_id = data.azurerm_key_vault.dps_cert.id

  tenant_id = var.tenant_id
  object_id = azuread_service_principal.xxxx-kv-read-sp.id

  key_permissions         = ["get"]
  secret_permissions      = ["get"]
  certificate_permissions = ["get"]
}
