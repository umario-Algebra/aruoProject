variable "location"       { type = string }
variable "tags"           { type = map(string) }
variable "rg_core_name"   { type = string }
variable "rg_net_name"    { type = string }
variable "vnet_core_name" { type = string }
variable "vnet_jump_name" { type = string }

# Non-overlapping CIDRs
locals {
  vnet_core_cidr = "10.10.0.0/16"
  vnet_jump_cidr = "10.20.0.0/24"
}

resource "azurerm_virtual_network" "core" {
  name                = var.vnet_core_name
  location            = var.location
  resource_group_name = var.rg_core_name
  address_space       = [local.vnet_core_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "snet_aks" {
  name                 = "snet-aks"
  resource_group_name  = var.rg_core_name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.10.10.0/24"]
}

resource "azurerm_subnet" "snet_appgw" {
  name                 = "snet-appgw"
  resource_group_name  = var.rg_core_name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.10.20.0/24"]
}

resource "azurerm_subnet" "snet_func" {
  name                 = "snet-func"
  resource_group_name  = var.rg_core_name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.10.30.0/24"]
}

resource "azurerm_subnet" "snet_pg" {
  name                 = "snet-pg"
  resource_group_name  = var.rg_core_name
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = ["10.10.40.0/24"]
}

# Jump VNET
resource "azurerm_virtual_network" "jump" {
  name                = var.vnet_jump_name
  location            = var.location
  resource_group_name = var.rg_net_name
  address_space       = [local.vnet_jump_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "snet_jump" {
  name                 = "snet-jump"
  resource_group_name  = var.rg_net_name
  virtual_network_name = azurerm_virtual_network.jump.name
  address_prefixes     = ["10.20.0.0/27"]
}

# Empty NSG for jump (rules later)
resource "azurerm_network_security_group" "nsg_jump" {
  name                = "nsg-jump"
  location            = var.location
  resource_group_name = var.rg_net_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "assoc_jump" {
  subnet_id                 = azurerm_subnet.snet_jump.id
  network_security_group_id = azurerm_network_security_group.nsg_jump.id
}

output "vnet_core_id" { value = azurerm_virtual_network.core.id }
output "vnet_jump_id" { value = azurerm_virtual_network.jump.id }
