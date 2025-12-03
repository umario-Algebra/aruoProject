variable "location"     { type = string }
variable "rg_name"      { type = string }
variable "account_name" { type = string }   # e.g. stgaruopdev001
variable "allow_public" {
  type    = bool
  default = true
}
variable "tags" { type = map(string) }

resource "azurerm_storage_account" "this" {
  name                     = var.account_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version               = "TLS1_2"
  enable_https_traffic_only     = true
  public_network_access_enabled = var.allow_public

  tags = var.tags
}

locals {
  primary_conn = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.this.name};AccountKey=${azurerm_storage_account.this.primary_access_key};EndpointSuffix=core.windows.net"
}

output "id"            { value = azurerm_storage_account.this.id }
output "name"          { value = azurerm_storage_account.this.name }
output "blob_endpoint" { value = azurerm_storage_account.this.primary_blob_endpoint }

output "primary_access_key" {
  value     = azurerm_storage_account.this.primary_access_key
  sensitive = true
}

output "connection_string" {
  value     = local.primary_conn
  sensitive = true
}
