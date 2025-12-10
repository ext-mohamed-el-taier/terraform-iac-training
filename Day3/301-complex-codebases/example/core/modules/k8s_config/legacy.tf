# Fetch AD reader group for product
data "azuread_group" "reader" {
  for_each = local.legacy_products
  name     = each.value["ad_reader_group_name"]
}

# Fetch AD contributor group for product
data "azuread_group" "contributor" {
  for_each = local.legacy_products
  name     = each.value["ad_contributor_group_name"]
}

# AKS access - AKS Service Users aligned to product reader group in AD
resource "azurerm_role_assignment" "aks-user" {
  for_each             = local.legacy_aks_roles["user"]
  scope                = var.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = data.azuread_group.reader[each.key].id
}

# AKS admins - AKS Service Admins aligned to product contributor group in AD
resource "azurerm_role_assignment" "aks-admin" {
  for_each             = local.legacy_products
  scope                = var.aks_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = data.azuread_group.contributor[each.key].id
}

# k8s ClusterRoleBinding for product - cluster-wide viewers bound to product reader group in AD if product specifies "is_k8s_viewer"
resource "kubernetes_cluster_role_binding" "cluster_viewers" {
  for_each = local.legacy_k8s_roles["viewer"]
  metadata {
    name = "${each.key}-cluster-users-crb"
  }

  subject {
    kind      = "Group"
    name      = data.azuread_group.reader[each.key].id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}

# k8s ClusterRoleBinding for product - cluster-wide admins bound to product contributor group in AD if product specifies "is_k8s_admin"
resource "kubernetes_cluster_role_binding" "cluster_admins" {
  for_each = local.legacy_k8s_roles["cluster-admin"]
  metadata {
    name = "${each.key}-cluster-admins-crb"
  }

  subject {
    kind      = "Group"
    name      = data.azuread_group.contributor[each.key].id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

# k8s RoleBinding for product namespace - namespace viewers bound to product reader group in AD
resource "kubernetes_role_binding" "namespace_viewers" {
  for_each = local.legacy_products
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-viewers-rb"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  subject {
    kind      = "Group"
    name      = data.azuread_group.reader[each.key].id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }
}

# k8s RoleBinding for product namespace - namespace admin bound to product contributor group in AD
resource "kubernetes_role_binding" "namespace_admins" {
  for_each = local.legacy_products
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-admins-rb"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  subject {
    kind      = "Group"
    name      = data.azuread_group.contributor[each.key].id
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

# k8s RoleBinding for product namespace - namespace admin bound to product deployment service principal
resource "kubernetes_role_binding" "namespace_admin_service_principal" {
  for_each = local.legacy_products
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-admins-sp-rb"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  subject {
    kind      = "Group"
    name      = each.value["deployment_sp_client_id"]
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Create non-AD ServiceAccount in k8s for ADO Service connections (legacy)

resource "kubernetes_service_account" "product" {
  for_each = local.legacy_products
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-sa"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }
}

# Get token for SA for TF statefile output
# In future, store in secret storage (Vault/Key Vault/etc)
data "kubernetes_secret" "sa_secret" {
  for_each = kubernetes_service_account.product
  metadata {
    name      = each.value.default_secret_name
    namespace = each.value.metadata.0.namespace
  }

}

resource "azurerm_key_vault_secret" "sa-token" {
  for_each     = local.legacy_products
  name         = "${each.key}-${var.location}-sa-token"
  key_vault_id = var.environment_keyvault_id
  value        = lookup(data.kubernetes_secret.sa_secret[each.key].data, "token", "")
  content_type = "k8s-sa-token"
}

resource "azurerm_key_vault_secret" "sa-cert" {
  for_each     = local.legacy_products
  name         = "${each.key}-${var.location}-sa-cert"
  key_vault_id = var.environment_keyvault_id
  value        = lookup(data.kubernetes_secret.sa_secret[each.key].data, "ca.crt", "")
  content_type = "k8s-sa-cert"
}

resource "azurerm_key_vault_secret" "sa-kubeconfig" {
  for_each     = local.legacy_products
  name         = "${var.environment}-${var.location}-${each.key}"
  key_vault_id = var.environment_keyvault_id
  value = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_fqdn    = var.cluster_fqdn,
    namespace       = kubernetes_namespace.product[each.key].metadata.0.name,
    service_account = kubernetes_service_account.product[each.key].metadata.0.name,
    token           = "${lookup(data.kubernetes_secret.sa_secret[each.key].data, "token", "")}",
    cert            = "${lookup(data.kubernetes_secret.sa_secret[each.key].data, "ca.crt", "")}"
  })
  content_type = "k8s-kubeconfig"
  tags = {
    url   = "https://${var.cluster_fqdn}:443"
    realm = var.realm
    owner = each.value["ad_contributor_group_name"]
  }
}

# Service accounts are cluster-admins in their namespace
resource "kubernetes_role_binding" "service_account" {
  for_each = local.legacy_products
  metadata {
    name      = "${kubernetes_namespace.product[each.key].metadata.0.name}-rb"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.product[each.key].metadata.0.namespace}-sa"
    namespace = kubernetes_service_account.product[each.key].metadata.0.namespace # NS the SA is in
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Config map with runtime configuration
# Should be used for product repo based inputs only
resource "kubernetes_config_map" "platform_product" {
  for_each = local.legacy_products
  metadata {
    name      = "platform-config"
    namespace = kubernetes_namespace.product[each.key].metadata.0.name
  }

  data = {
    product_app_id = each.value.product_runtime_sp_client_id
  }
}

# Tiller for Helm 2 (legacy, deprecated)

module "tiller-edge" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = "edge"
  module_depends_on = [kubernetes_namespace.product]
}

module "tiller-leap" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = "leap"
  module_depends_on = [kubernetes_namespace.product]
}

module "tiller-xxxx" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = "xxxx"
  is_cluster_role   = true
  module_depends_on = [kubernetes_namespace.product]
}

module "tiller-observability" {
  source            = "git::https://xxxx-rd.visualstudio.com/Platform/_git/tf_k8s_tiller?ref=1.0.4"
  location          = var.location
  keyvault_id       = var.environment_keyvault_id
  namespace         = "observability"
  is_cluster_role   = true
  module_depends_on = [kubernetes_namespace.product]
}


