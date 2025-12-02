variable "location" { type = string }
variable "rg_name"  { type = string }
variable "kv_name"  { type = string }
variable "tags"     { type = map(string) }

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.kv_name
  location                      = var.location
  resource_group_name           = var.rg_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"

  soft_delete_retention_days    = 7
  purge_protection_enabled      = false

  enable_rbac_authorization     = true
  public_network_access_enabled = true

  tags = var.tags
}

output "kv_id"   { value = azurerm_key_vault.this.id }
output "kv_name" { value = azurerm_key_vault.this.name }
