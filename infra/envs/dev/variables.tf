variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "location_dr" {
  type    = string
  default = "northeurope"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "project" {
  type    = string
  default = "aruop"
}

variable "tags" {
  type = map(string)
  default = {
    university = "Algebra"
    student    = "umario@algebra.hr"
    project    = "aruo"
    env        = "dev"
    owner      = "umario"
    costCenter = "000"
  }
}

variable "sku" {
  type = object({
    vm_jump_size : string
    aks_node_size : string
    postgres_sku : string
    appgw_sku : string
    storage_repl : string
    kv_sku : string
    acr_sku : string
  })

  default = {
    vm_jump_size  = "Standard_B2ats_v2"
    aks_node_size = "Standard_B2ms"
    postgres_sku  = "B_Standard_B1ms"
    appgw_sku     = "WAF_v2"
    storage_repl  = "LRS"
    kv_sku        = "standard"
    acr_sku       = "Standard"
  }
}

variable "jump_admin_username" {
  type        = string
  default     = "localadmin"
  description = "Admin username for the jump Windows VM."
}

variable "jump_admin_password" {
  type        = string
  description = "Admin password for the jump Windows VM."
  sensitive   = true
}

variable "pg_admin_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the PostgreSQL Flexible Server."
}

