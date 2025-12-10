# Add AD groups that contain developer roles to products in order to set k8s access
# This will be a global object in the future, but pull from var.products and merge for now
locals {
  # legacy products refers to pre 1.9.0 tag of this repo. These products are being deprecated in favor of upstream products repo
  # These will be removed when the platform is "cut over" to the new product-based security roles
  legacy_products = {
    xxxx = {
      ad_reader_group_name          = "xxxxauth_app_platform_reader_${var.realm}"
      ad_contributor_group_name     = "xxxxauth_app_platform_contributor_${var.realm}"
      deployment_sp_client_id       = var.products_from_base["xxxx"].deployment_sp_client_id
      product_runtime_sp_client_id  = var.products["xxxx"].platform.product_runtime_app_client_id
      is_aks_admin                  = true
      is_aks_user                   = true
      is_k8s_admin                  = true
      is_k8s_viewer                 = true
      can_read_from_shared_keyvault = true
    }
    edge = {
      ad_reader_group_name          = "xxxxauth_app_edge_reader_${var.realm}"
      ad_contributor_group_name     = "xxxxauth_app_edge_contributor_${var.realm}"
      deployment_sp_client_id       = var.products_from_base["edge"].deployment_sp_client_id
      product_runtime_sp_client_id  = var.products["edge"].platform.product_runtime_app_client_id
      is_aks_admin                  = false
      is_aks_user                   = true
      is_k8s_admin                  = false
      is_k8s_viewer                 = false
      can_read_from_shared_keyvault = true
    }
    leap = {
      ad_reader_group_name          = "xxxxauth_app_leap_reader_${var.realm}"
      ad_contributor_group_name     = "xxxxauth_app_leap_contributor_${var.realm}"
      deployment_sp_client_id       = var.products_from_base["leap"].deployment_sp_client_id
      product_runtime_sp_client_id  = var.products["leap"].platform.product_runtime_app_client_id
      is_aks_admin                  = false
      is_aks_user                   = true
      is_k8s_admin                  = false
      is_k8s_viewer                 = false
      can_read_from_shared_keyvault = true
    }
    observability = {
      ad_reader_group_name          = "xxxxauth_app_observability_reader_${var.realm}"
      ad_contributor_group_name     = "xxxxauth_app_observability_contributor_${var.realm}"
      deployment_sp_client_id       = var.products_from_base["observability"].deployment_sp_client_id
      product_runtime_sp_client_id  = var.products["observability"].platform.product_runtime_app_client_id
      is_aks_admin                  = false
      is_aks_user                   = true
      is_k8s_admin                  = true
      is_k8s_viewer                 = false
      can_read_from_shared_keyvault = true
    }
  }

  legacy_aks_roles = {
    admin = { for product, properties in local.legacy_products : product => properties... if properties.is_aks_admin }
    user  = { for product, properties in local.legacy_products : product => properties... if properties.is_aks_user }
  }

  legacy_k8s_roles = {
    cluster-admin = { for product, properties in local.legacy_products : product => properties... if properties.is_k8s_admin }
    viewer        = { for product, properties in local.legacy_products : product => properties... if properties.is_k8s_viewer }
  }

  legacy_keyvault_roles = {
    shared-reader = { for product, properties in local.legacy_products : product => properties... if properties.can_read_from_shared_keyvault }
  }

  # Product-based roles sourced from [upstream products repo](https://xxxx-rd.visualstudio.com/Platform/_git/product?path=%2F&version=GBmaster&_a=contents)
  aks_roles = {
    user = { for product, properties in var.products : product => properties.features.aks if properties.features.aks.product_aks_user_group_id != null }
  }
  k8s_roles = {
    global-viewer = { for product, properties in var.products : product => properties.features.k8s if properties.features.k8s.product_k8s_global_viewer_group_id != null }
  }
  namespaces = { for product, properties in var.products : product => properties.features.k8s.namespace if properties.features.k8s.namespace.enabled }
  keyvault_roles = {
    shared-reader = { for product, properties in var.products : product => properties.features.k8s if(properties.features.k8s.can_read_from_shared_key_vault != null ? properties.features.k8s.can_read_from_shared_key_vault : false) }
  }
}
