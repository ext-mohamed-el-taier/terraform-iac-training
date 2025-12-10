output "app_id" {
  value = azuread_service_principal.xxxx-metrics-read-sp.application_id
}

output "password" {
  value = azuread_service_principal_password.xxxx-metrics-read-sp-pw.value
}

output "service_principal_id" {
  value = azuread_service_principal.xxxx-metrics-read-sp.id
}

output "azuread_application_id" {
  value = azuread_application.xxxx-metrics-read-app.application_id
}

output "xxxx-metrics-read-random" {
  value = random_string.xxxx-metrics-read-random.result
}
