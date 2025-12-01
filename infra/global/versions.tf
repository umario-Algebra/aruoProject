terraform {
  required_version = "~> 1.9.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.117" }
    azapi  = { source = "azure/azapi",        version = "~> 2.0" }
    random = { source = "hashicorp/random",   version = "~> 3.6" }
    time   = { source = "hashicorp/time",     version = "~> 0.11" }
  }
}
