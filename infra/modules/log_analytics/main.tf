variable "location"       { type = string }
variable "tags"           { type = map(string) }
variable "workspace_name" { type = string }
variable "rg_name"        { type = string }

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

output "workspace_id"   { value = azurerm_log_analytics_workspace.this.id }
output "workspace_name" { value = azurerm_log_analytics_workspace.this.name }
