# AKS - metric reader scope integration
locals {
  sp_suffix = "${var.location}-xxxx-metrics-read"
}

resource "azuread_application" "xxxx-metrics-read-app" {
  name                       = "${var.cluster_id}-${local.sp_suffix}"
  homepage                   = "https://${var.cluster_id}-${local.sp_suffix}"
  identifier_uris            = ["https://${var.cluster_id}-${local.sp_suffix}"]
  reply_urls                 = ["https://${var.cluster_id}-${local.sp_suffix}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "xxxx-metrics-read-sp" {
  application_id = azuread_application.xxxx-metrics-read-app.application_id
}

resource "random_string" "xxxx-metrics-read-random" {
  length  = 32
  special = false

  keepers = {
    aks_cluster = "${var.aks_cluster_id}"
  }
}

resource "azuread_service_principal_password" "xxxx-metrics-read-sp-pw" {
  service_principal_id = azuread_service_principal.xxxx-metrics-read-sp.id
  value                = random_string.xxxx-metrics-read-random.result
  end_date             = "2029-01-03T01:02:00Z"
}

resource "azurerm_key_vault_secret" "xxxx-metrics-read-sp-pw" {
  name         = "xxxx-metrics-reader-sp-${var.location}"
  value        = azuread_service_principal_password.xxxx-metrics-read-sp-pw.value
  key_vault_id = var.keyvault_id
  content_type = "autogen-password"
}

resource "azurerm_role_assignment" "service-bus-read" {
  scope                = var.metric_scope
  role_definition_name = "Monitoring Reader"
  principal_id         = azuread_service_principal.xxxx-metrics-read-sp.id
}
