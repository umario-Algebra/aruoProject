resource "azurerm_private_dns_zone" "this" {
  name                = var.private_dns_zone_name
  resource_group_name = var.rg_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "core" {
  name                  = "${var.name}-core-vnet-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.core_vnet_id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.name
  resource_group_name = var.rg_name

  # HACK: DB in North Europe because West Europe is blocked for this subscription
  location = "northeurope"

  version               = var.pg_version
  sku_name              = var.sku_name
  storage_mb            = var.storage_mb
  backup_retention_days = var.backup_retention_days
  create_mode           = "Default"

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  # Public access enabled; we’ll restrict with firewall rules (via CLI) after creation.
  public_network_access_enabled = true

  authentication {
    password_auth_enabled         = true
    active_directory_auth_enabled = false
  }

  tags = var.tags
}


resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
