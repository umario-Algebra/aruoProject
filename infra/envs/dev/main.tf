terraform {
  backend "azurerm" {}
}

module "resource_groups" {
  source   = "../../modules/resource_group"
  location = var.location
  tags     = var.tags
  names    = local.names
}

module "network" {
  source               = "../../modules/network"
  location             = var.location
  tags                 = var.tags

  # VEŽEMO SE NA OUTPUTE, NE NA local.names
  rg_core_name         = module.resource_groups.rg_core_name
  rg_net_name          = module.resource_groups.rg_net_name

  vnet_core_name       = local.names.vnet_core
  vnet_jump_name       = local.names.vnet_jump
  jump_rdp_source_cidr = "85.10.62.66/32"
}

module "log_analytics" {
  source         = "../../modules/log_analytics"
  location       = var.location
  tags           = var.tags
  workspace_name = local.names.la

  # CORE RG iz modula
  rg_name        = module.resource_groups.rg_core_name
}

module "keyvault" {
  source   = "../../modules/keyvault"
  location = var.location

  # CORE RG iz modula
  rg_name  = module.resource_groups.rg_core_name

  kv_name  = local.names.kv
  tags     = var.tags
}

module "uami_aks" {
  source   = "../../modules/identity"
  location = var.location

  # SEC RG iz modula – OVO JE KRITIČNO
  rg_name  = module.resource_groups.rg_sec_name

  name     = local.names.uami_aks
  tags     = var.tags
}

module "uami_appg" {
  source   = "../../modules/identity"
  location = var.location

  # ISTO – SEC RG iz modula, ne string
  rg_name  = module.resource_groups.rg_sec_name

  name     = local.names.uami_appg
  tags     = var.tags
}

module "postgres" {
  source = "../../modules/postgres_flexible"

  location = "northeurope"

  # CORE RG iz modula, ne hard-coded string
  rg_name  = module.resource_groups.rg_core_name

  name     = "pg-aruop-dev-ne01"

  core_vnet_id        = module.network.core_vnet_id
  delegated_subnet_id = module.network.snet_pg_id

  administrator_login    = "pgadminuser"
  administrator_password = var.pg_admin_password

  database_name = "appdb"

  tags = {
    costCenter = "000"
    env        = "dev"
    owner      = "umario"
    project    = "aruo"
    student    = "umario@algebra.hr"
    university = "Algebra"
  }
}

module "rbac_appgw_kv_secrets" {
  source       = "../../modules/rbac_kv_secret_reader"
  kv_id        = module.keyvault.kv_id
  principal_id = module.uami_appg.principal_id
}

module "acr" {
  source   = "../../modules/acr"
  location = var.location

  # CORE RG iz modula
  rg_name  = module.resource_groups.rg_core_name

  acr_name = local.names.acr
  tags     = var.tags
}

module "rbac_acr_pull_for_aks" {
  source       = "../../modules/rbac_acr_pull"
  scope_id     = module.acr.id
  principal_id = module.uami_aks.principal_id
}

module "aks" {
  source       = "../../modules/aks"
  location     = var.location

  # CORE RG iz modula
  rg_name      = module.resource_groups.rg_core_name

  cluster_name = local.names.aks
  dns_prefix   = local.names.aks_dns
  subnet_id    = module.network.snet_aks_id
  node_size    = var.sku.aks_node_size
  node_count   = 1
  uami_id      = module.uami_aks.id
  la_ws_id     = module.log_analytics.workspace_id
  tags         = var.tags
}

module "rbac_acr_pull_for_kubelet" {
  source       = "../../modules/rbac_acr_pull"
  scope_id     = module.acr.id
  principal_id = module.aks.kubelet_id
}

module "st" {
  source       = "../../modules/storage_account"
  location     = var.location

  # CORE RG iz modula
  rg_name      = module.resource_groups.rg_core_name

  account_name = local.names.st
  allow_public = true
  tags         = var.tags
}

module "func_plan" {
  source    = "../../modules/function_plan"
  location  = var.location

  # CORE RG iz modula
  rg_name   = module.resource_groups.rg_core_name

  plan_name = local.names.funcplan
  tags      = var.tags
}

module "app_gateway" {
  source = "../../modules/app_gateway"

  location  = var.location

  # CORE RG iz modula (umjesto hard-coded "rg-aruop-dev-core")
  rg_name   = module.resource_groups.rg_core_name

  subnet_id = module.network.snet_appgw_id

  appgw_name = "agw-aruop-dev-01"
  pip_name   = "pip-aruop-dev-appgw"

  tags = {
    costCenter = "000"
    env        = "dev"
    owner      = "umario"
    project    = "aruo"
    student    = "umario@algebra.hr"
    university = "Algebra"
  }
}

module "func_app" {
  source = "../../modules/function_app"

  # CORE RG iz modula
  resource_group_name = module.resource_groups.rg_core_name

  function_app_name   = local.names.funcapp
  service_plan_id     = module.func_plan.id

  storage_account_name = module.st.name
  storage_account_key  = module.st.primary_access_key

  location = var.location
  tags     = var.tags

  # Ako tvoj modul podržava:
  # subnet_id    = module.network.snet_func_id
  # workspace_id = module.log_analytics.workspace_id
}

resource "azurerm_role_assignment" "kubelet_netcontrib_aks_subnet" {
  scope                = module.network.snet_aks_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.kubelet_object_id
}

resource "azurerm_role_assignment" "kubelet_netcontrib_ilb_subnet" {
  scope                = module.network.snet_ilb_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.kubelet_object_id
}

