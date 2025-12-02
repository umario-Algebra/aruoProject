variable "location" { type = string }
variable "rg_name"  { type = string }
variable "name"     { type = string }
variable "tags"     { type = map(string) }

resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
}

output "id"         { value = azurerm_user_assigned_identity.this.id }
output "client_id"  { value = azurerm_user_assigned_identity.this.client_id }
output "principal_id" { value = azurerm_user_assigned_identity.this.principal_id }
