data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "aks-product-user" {
  for_each             = local.aks_roles["user"]
  scope                = var.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value.product_aks_user_group_id
}

# k8s ClusterRoleBinding for product - cluster-wide viewers bound to product deployment group in AD if product specifies "is_k8s_viewer"
resource "kubernetes_cluster_role_binding" "product_cluster_viewers" {
  for_each = local.k8s_roles["global-viewer"]
  metadata {
    name = "${each.key}-product-cluster-viewers-crb"
  }

  subject {
    kind      = "Group"
    name      = each.value.product_k8s_global_viewer_group_id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Create a k8s namespace per product
resource "kubernetes_namespace" "product" {
  for_each = local.namespaces
  metadata {
    annotations = each.value.annotations
    labels      = each.value.labels
    name        = each.value.name
  }
}

# Create a k8s namespace limit per product
resource "kubernetes_limit_range" "limit-range" {
  for_each = local.namespaces
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-limit-range"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = "50m"
        memory = "75Mi"
      }

      default_request = {
        cpu    = "30m"
        memory = "50Mi"
      }
    }
  }
}

# k8s RoleBinding for product namespace - namespace viewers bound to product namespace viewer group
resource "kubernetes_role_binding" "product_namespace_viewers" {
  for_each = local.namespaces
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-product-viewers-rb"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  subject {
    kind      = "Group"
    name      = each.value.product_namespace_viewer_group_id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}

# k8s RoleBinding for product namespace - namespace admin bound to product namespace admin group
resource "kubernetes_role_binding" "product_namespace_admins" {
  for_each = local.namespaces
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-product-admins-rb"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  subject {
    kind      = "Group"
    name      = each.value.product_namespace_admin_group_id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Setup flexvol for Azure KV access in xxxx namespace
module "flexvol" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_flexvol?ref=1.2.1"
  app               = "keyvault-flexvolume"
  namespace         = "xxxx"
  module_depends_on = [kubernetes_namespace.product]
}

# Create Azure KV readers for flexvol
module "keyvault-reader" {
  source            = "../keyvault_reader"
  cluster_id        = var.environment
  aks_cluster_id    = var.aks_id
  dps_cert_keyvault = var.dps_intermediate_keyvault_name
  keyvault_id       = var.environment_keyvault_id
  tenant_id         = data.azurerm_client_config.current.tenant_id
  realm             = var.realm
  location          = var.location
}

# Create Secret in each namespace for access to KV using flexvol if product "can_read_from_shared_keyvault"
resource "kubernetes_secret" "keyvault-sp-reader" {
  for_each = local.keyvault_roles["shared-reader"]
  metadata {
    name      = "${each.key}-keyvault-sp-reader"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  data = {
    clientid     = module.keyvault-reader.app_id
    clientsecret = module.keyvault-reader.password
  }

  type = "azure/kv"
}

# Resources that aren't products (yet)

module "tiller-kube-system" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = "kube-system"
  is_cluster_role   = true
  module_depends_on = [kubernetes_namespace.product]
}

data "azurerm_resource_group" "xxxx_iot_resources" {
  name = "${var.environment}-iot_resources"
}

resource "kubernetes_secret" "azure-k8s-metrics-adapter" {
  metadata {
    name      = "azure-external-metrics-azure-k8s-metrics-adapter"
    namespace = module.namespace-custom-metrics.namespace
  }

  data = {
    azure-tenant-id     = data.azurerm_client_config.current.tenant_id
    azure-client-id     = module.metrics-reader.azuread_application_id
    azure-client-secret = module.metrics-reader.xxxx-metrics-read-random
  }

  type = "kubernetes.io/generic"
}

module "namespace-custom-metrics" {
  source              = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_namespace?ref=1.1.2"
  environment         = var.environment
  app_id              = "custom-metrics"
  location            = var.location
  cluster_fqdn        = var.cluster_fqdn
  elevated_role       = true
  keyvault_id         = var.environment_keyvault_id
  kv_sp_reader_app_id = module.keyvault-reader.app_id
  kv_sp_reader_pw     = module.keyvault-reader.password
  user_group_name     = "xxxxauth_app_platform_reader_${var.realm}"
  admin_group_name    = "xxxxauth_app_platform_contributor_${var.realm}"
}

resource "azurerm_key_vault_secret" "sa-kubeconfig-custom-metrics" {
  name         = "${var.environment}-${var.location}-custom-metrics"
  key_vault_id = var.environment_keyvault_id
  value        = module.namespace-custom-metrics.namespace_sa_kubeconfig
  content_type = "k8s-kubeconfig"
  tags = {
    url   = "https://${var.cluster_fqdn}:443"
    realm = var.realm
    owner = "xxxxauth_app_platform_contributor_nonprod"
  }
}

module "tiller-custom-metrics" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = module.namespace-custom-metrics.namespace
  is_cluster_role   = true
  module_depends_on = [kubernetes_namespace.product]
}

resource "kubernetes_namespace" "istio-system" {
  metadata {
    annotations = {}
    labels      = {}
    name        = "istio-system"
  }
}

# This secret bootstraps the cert for Istio
# According to the Istio docs, if the ca-cert and root-cert match, the chain can be empty. 
resource "kubernetes_secret" "istio-cacerts" {
  metadata {
    name      = "cacerts"
    namespace = kubernetes_namespace.istio-system.metadata.0.name
  }

  data = {
    "ca-cert.pem"    = var.ca-cert
    "ca-key.pem"     = var.ca-key
    "cert-chain.pem" = var.ca-chain
    "root-cert.pem"  = var.ca-root == null ? var.ca-cert : var.ca-root
  }

  type = "Opaque"
}

module "metrics-reader" {
  source         = "../metrics_reader"
  cluster_id     = var.environment
  aks_cluster_id = var.aks_id
  keyvault_id    = var.environment_keyvault_id
  tenant_id      = data.azurerm_client_config.current.tenant_id
  realm          = var.realm
  location       = var.location
  metric_scope   = data.azurerm_resource_group.xxxx_iot_resources.id
}

module "namespace-ingress" {
  source              = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_namespace?ref=1.1.2"
  environment         = var.environment
  app_id              = "ingress"
  location            = var.location
  cluster_fqdn        = var.cluster_fqdn
  elevated_role       = true
  keyvault_id         = var.environment_keyvault_id
  kv_sp_reader_app_id = module.keyvault-reader.app_id
  kv_sp_reader_pw     = module.keyvault-reader.password
  user_group_name     = "xxxxauth_app_platform_reader_${var.realm}"
  admin_group_name    = "xxxxauth_app_platform_contributor_${var.realm}"
}

resource "azurerm_key_vault_secret" "sa-kubeconfig-ingress" {
  name         = "${var.environment}-${var.location}-ingress"
  key_vault_id = var.environment_keyvault_id
  value        = module.namespace-ingress.namespace_sa_kubeconfig
  content_type = "k8s-kubeconfig"
  tags = {
    url   = "https://${var.cluster_fqdn}:443"
    realm = var.realm
    owner = "xxxxauth_app_platform_contributor_nonprod"
  }
}

module "tiller-ingress" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = module.namespace-ingress.namespace
  is_cluster_role   = true
  module_depends_on = [kubernetes_namespace.product]
}

data "azuread_group" "users-vaml" {
  name = "xxxxauth_app_va_reader_${var.realm}"
}

resource "azurerm_role_assignment" "aks-user-vaml" {
  scope                = var.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.users-vaml.id
}

module "namespace-vaml" {
  source              = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_namespace?ref=1.1.2"
  environment         = var.environment
  app_id              = "vaml"
  location            = var.location
  cluster_fqdn        = var.cluster_fqdn
  keyvault_id         = var.environment_keyvault_id
  kv_sp_reader_app_id = module.keyvault-reader.app_id
  kv_sp_reader_pw     = module.keyvault-reader.password
  user_group_name     = "xxxxauth_app_va_reader_${var.realm}"
  admin_group_name    = "xxxxauth_app_va_contributor_${var.realm}"
}

resource "azurerm_key_vault_secret" "sa-kubeconfig-vaml" {
  name         = "${var.environment}-${var.location}-vaml"
  key_vault_id = var.environment_keyvault_id
  value        = module.namespace-vaml.namespace_sa_kubeconfig
  content_type = "k8s-kubeconfig"
  tags = {
    url   = "https://${var.cluster_fqdn}:443"
    realm = var.realm
    owner = "xxxxauth_app_va_contributor_nonprod"
  }
}

module "tiller-vaml" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = module.namespace-vaml.namespace
  module_depends_on = [kubernetes_namespace.product]
}
