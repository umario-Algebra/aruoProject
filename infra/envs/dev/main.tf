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
  source            = "../../modules/network"
  location          = var.location
  tags              = var.tags
  rg_core_name      = local.names.rg_core
  rg_net_name       = local.names.rg_net
  vnet_core_name    = local.names.vnet_core
  vnet_jump_name    = local.names.vnet_jump
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
