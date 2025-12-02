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
