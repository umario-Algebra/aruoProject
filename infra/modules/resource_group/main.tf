variable "location" { type = string }
variable "tags"     { type = map(string) }
variable "names"    { type = map(string) }

resource "azurerm_resource_group" "core" {
  name     = var.names.rg_core
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "net" {
  name     = var.names.rg_net
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "sec" {
  name     = var.names.rg_sec
  location = var.location
  tags     = var.tags
}

output "rg_core_name" { value = azurerm_resource_group.core.name }
output "rg_net_name"  { value = azurerm_resource_group.net.name }
output "rg_sec_name"  { value = azurerm_resource_group.sec.name }
