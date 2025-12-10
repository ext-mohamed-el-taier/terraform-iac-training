output "app_id" {
  value = azuread_service_principal.xxxx-kv-read-sp.application_id
}

output "password" {
  value = azuread_service_principal_password.xxxx-kv-read-sp-pw.value
}

output "service_principal_id" {
  value = azuread_service_principal.xxxx-kv-read-sp.id
}
