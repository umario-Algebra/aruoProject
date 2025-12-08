variable "location"            { type = string }
variable "rg_name"             { type = string }
variable "name"                { type = string } # e.g. pg-aruop-dev-01

variable "core_vnet_id"        { type = string }
variable "delegated_subnet_id" { type = string }

variable "administrator_login" {
  type        = string
  description = "Admin login name for PostgreSQL."
}

variable "administrator_password" {
  type        = string
  sensitive   = true
  description = "Admin password for PostgreSQL."
}

variable "database_name" {
  type        = string
  description = "Name of the default database to create."
}

variable "tags" {
  type = map(string)
}

variable "sku_name" {
  type        = string
  default     = "B_Standard_B1ms"
  description = "PostgreSQL Flexible Server SKU (B1ms)."
}

variable "pg_version" {
  type        = string
  default     = "16"
  description = "PostgreSQL major version."
}

variable "storage_mb" {
  type        = number
  default     = 32768 # 32 GB
}

variable "backup_retention_days" {
  type        = number
  default     = 7
}

variable "zone" {
  type        = string
  default     = "1"
  description = "Availability zone."
}

variable "private_dns_zone_name" {
  type        = string
  default     = "privatelink.postgres.database.azure.com"
}
