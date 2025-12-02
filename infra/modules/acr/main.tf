variable "location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "acr_name" {
  type = string
}
variable "sku" {
  type    = string
  default = "Standard"
}
variable "tags" {
  type = map(string)
}

resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false
  tags                = var.tags
}

output "id"           { value = azurerm_container_registry.this.id }
output "login_server" { value = azurerm_container_registry.this.login_server }
output "name"         { value = azurerm_container_registry.this.name }
