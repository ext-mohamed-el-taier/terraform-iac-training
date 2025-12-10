output "aks_endpoint_fqdn" {
  value = var.cluster_fqdn
}

output "xxxx_kv_read_sp_client_id" {
  value = module.keyvault-reader.service_principal_id
}

output "kube_system_tiller_name" {
  value = module.tiller-kube-system.service_account_name
}

output "kube_system_tiller_token" {
  value     = module.tiller-kube-system.service_account_token
  sensitive = true
}

output "edge_tiller_name" {
  value = module.tiller-edge.service_account_name
}

output "edge_tiller_secret" {
  value = module.tiller-edge.service_account_secret
}

output "leap_tiller_name" {
  value = module.tiller-leap.service_account_name
}

output "leap_tiller_secret" {
  value = module.tiller-leap.service_account_secret
}

output "xxxx_tiller_name" {
  value = module.tiller-xxxx.service_account_name
}

output "xxxx_tiller_secret" {
  value = module.tiller-xxxx.service_account_secret
}

output "ingress_sa_token" {
  value     = module.namespace-ingress.sa_token
  sensitive = true
}

output "ingress_sa_name" {
  value = module.namespace-ingress.sa_account_name
}

output "ingress_sa_secret" {
  value = module.namespace-ingress.sa_secret_name
}

output "ingress_tiller_name" {
  value = module.tiller-ingress.service_account_name
}

output "ingress_tiller_secret" {
  value = module.tiller-ingress.service_account_secret
}

output "vaml_sa_token" {
  value     = module.namespace-vaml.sa_token
  sensitive = true
}

output "vaml_sa_name" {
  value = module.namespace-vaml.sa_account_name
}

output "vaml_sa_secret" {
  value = module.namespace-vaml.sa_secret_name
}

output "vaml_tiller_name" {
  value = module.tiller-vaml.service_account_name
}

output "vaml_tiller_secret" {
  value = module.tiller-vaml.service_account_secret
}

