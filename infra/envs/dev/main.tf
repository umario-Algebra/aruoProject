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
  rg_core_name         = local.names.rg_core
  rg_net_name          = local.names.rg_net
  vnet_core_name       = local.names.vnet_core
  vnet_jump_name       = local.names.vnet_jump
  jump_rdp_source_cidr = "85.10.62.66/32"
}
module "log_analytics" {
  source         = "../../modules/log_analytics"
  location       = var.location
  tags           = var.tags
  workspace_name = local.names.la
  rg_name        = local.names.rg_core
}

module "keyvault" {
  source   = "../../modules/keyvault"
  location = var.location
  rg_name  = local.names.rg_core
  kv_name  = local.names.kv
  tags     = var.tags
}

module "uami_aks" {
  source   = "../../modules/identity"
  location = var.location
  rg_name  = local.names.rg_sec
  name     = local.names.uami_aks
  tags     = var.tags
}

module "uami_appg" {
  source   = "../../modules/identity"
  location = var.location
  rg_name  = local.names.rg_sec
  name     = local.names.uami_appg
  tags     = var.tags
}

module "postgres" {
  source = "../../modules/postgres_flexible"

  location = "northeurope"
  rg_name  = "rg-aruop-dev-core"
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
  rg_name  = local.names.rg_core
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
  rg_name      = local.names.rg_core
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
  rg_name      = local.names.rg_core
  account_name = local.names.st
  allow_public = true
  tags         = var.tags
}
module "func_plan" {
  source    = "../../modules/function_plan"
  location  = var.location
  rg_name   = local.names.rg_core
  plan_name = local.names.funcplan
  tags      = var.tags
}

module "app_gateway" {
  source = "../../modules/app_gateway"

  location  = var.location
  rg_name   = "rg-aruop-dev-core"
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

  resource_group_name = local.names.rg_core
  function_app_name   = local.names.funcapp
  service_plan_id     = module.func_plan.id

  # from storage_account module outputs you just fixed
  storage_account_name = module.st.name
  storage_account_key  = module.st.primary_access_key

  location = var.location
  tags     = var.tags

  # If your module has optional inputs, wire them here (only if defined):
  # subnet_id          = module.network.snet_func_id
  # workspace_id       = module.log_analytics.workspace_id
}

