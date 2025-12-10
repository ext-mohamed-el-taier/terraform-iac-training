
output "xxxx_kv_read_sp_client_id" {
  value = module.k8s-config-eastus2.xxxx_kv_read_sp_client_id
}

output "kube_system_tiller_name" {
  value = module.k8s-config-eastus2.kube_system_tiller_name
}

output "kube_system_tiller_token" {
  value     = module.k8s-config-eastus2.kube_system_tiller_token
  sensitive = true
}

output "edge_tiller_name" {
  value = module.k8s-config-eastus2.edge_tiller_name
}

output "edge_tiller_secret" {
  value = module.k8s-config-eastus2.edge_tiller_secret
}

output "leap_tiller_name" {
  value = module.k8s-config-eastus2.leap_tiller_name
}

output "leap_tiller_secret" {
  value = module.k8s-config-eastus2.leap_tiller_secret
}

output "xxxx_tiller_name" {
  value = module.k8s-config-eastus2.xxxx_tiller_name
}

output "xxxx_tiller_secret" {
  value = module.k8s-config-eastus2.xxxx_tiller_secret
}

output "ingress_sa_token" {
  value     = module.k8s-config-eastus2.ingress_sa_token
  sensitive = true
}

output "ingress_sa_name" {
  value = module.k8s-config-eastus2.ingress_sa_name
}

output "ingress_sa_secret" {
  value = module.k8s-config-eastus2.ingress_sa_secret
}

output "ingress_tiller_name" {
  value = module.k8s-config-eastus2.ingress_tiller_name
}

output "ingress_tiller_secret" {
  value = module.k8s-config-eastus2.ingress_tiller_secret
}

output "vaml_sa_token" {
  value     = module.k8s-config-eastus2.vaml_sa_token
  sensitive = true
}

output "vaml_sa_name" {
  value = module.k8s-config-eastus2.vaml_sa_name
}

output "vaml_sa_secret" {
  value = module.k8s-config-eastus2.vaml_sa_secret
}

output "vaml_tiller_name" {
  value = module.k8s-config-eastus2.vaml_tiller_name
}

output "vaml_tiller_secret" {
  value = module.k8s-config-eastus2.vaml_tiller_secret
}

