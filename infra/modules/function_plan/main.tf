variable "location"  { type = string }
variable "rg_name"   { type = string }
variable "plan_name" { type = string }   # e.g. plan-aruop-dev-func
variable "tags"      { type = map(string) }

# Consumption plan for Azure Functions (Linux)
resource "azurerm_service_plan" "this" {
  name                = var.plan_name
  resource_group_name = var.rg_name
  location            = var.location

  os_type  = "Linux"
  sku_name = "Y1"           # Consumption
  tags     = var.tags
}

output "id"   { value = azurerm_service_plan.this.id }
output "name" { value = azurerm_service_plan.this.name }
