variable "location"            { type = string }
variable "resource_group_name" { type = string }
variable "tags"                { type = map(string) }

# App Service Plan (Linux Consumption Y1) id
variable "service_plan_id"     { type = string }

# Storage account used by the Functions host
variable "storage_account_name" { type = string }
variable "storage_account_key"  { type = string }

# Function App name
variable "function_app_name"    { type = string }

resource "azurerm_linux_function_app" "this" {
  name                = var.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.service_plan_id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key

  https_only                    = true
  public_network_access_enabled = true
  tags                          = var.tags

  site_config {
    application_stack { 
      python_version = "3.11" 
    }

    ftps_state        = "Disabled"
    health_check_path = "/api/healthz"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME    = "python"
    FUNCTIONS_EXTENSION_VERSION = "~4"
    WEBSITE_RUN_FROM_PACKAGE    = "1"
    AzureWebJobsStorage         = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_key};EndpointSuffix=core.windows.net"
  }
}


output "default_hostname" {
  value = azurerm_linux_function_app.this.default_hostname
}
