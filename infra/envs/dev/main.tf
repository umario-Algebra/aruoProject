terraform {
  backend "azurerm" {}
}

module "resource_groups" {
  source   = "../../modules/resource_group"
  location = var.location
  tags     = var.tags
  names    = local.names
}
