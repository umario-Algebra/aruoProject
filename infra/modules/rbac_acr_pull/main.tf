variable "scope_id"      { type = string }   # ACR resource id
variable "principal_id"  { type = string }   # UAMI principal (object) id

resource "azurerm_role_assignment" "this" {
  scope                = var.scope_id
  role_definition_name = "AcrPull"
  principal_id         = var.principal_id
}

output "role_assignment_id" { value = azurerm_role_assignment.this.id }
