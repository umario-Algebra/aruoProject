variable "kv_id"         { type = string }
variable "principal_id"  { type = string }

resource "azurerm_role_assignment" "this" {
  scope                = var.kv_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.principal_id
}

output "role_assignment_id" { value = azurerm_role_assignment.this.id }
