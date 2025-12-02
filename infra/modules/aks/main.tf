variable "location"     { type = string }
variable "rg_name"      { type = string }
variable "cluster_name" { type = string }
variable "dns_prefix"   { type = string }
variable "subnet_id"    { type = string }   # snet-aks ID
variable "node_size" {
  type    = string
  default = "Standard_B2ms"
}
variable "node_count" {
  type    = number
  default = 1
}
variable "uami_id"   { type = string }      # user-assigned identity id
variable "la_ws_id"  { type = string }      # Log Analytics workspace id
variable "tags"      { type = map(string) }

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = var.dns_prefix
  tags                = var.tags

  kubernetes_version  = null

  default_node_pool {
    name                            = "nodepool1"
    vm_size                         = var.node_size
    node_count                      = var.node_count
    vnet_subnet_id                  = var.subnet_id
    type                            = "VirtualMachineScaleSets"
    os_disk_size_gb                 = 64
    only_critical_addons_enabled    = false
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.uami_id]
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "10.200.0.0/16"
    dns_service_ip     = "10.200.0.10"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }

  oms_agent {
    log_analytics_workspace_id = var.la_ws_id
  }

  azure_policy_enabled                 = false
  role_based_access_control_enabled    = true
}

output "id"         { value = azurerm_kubernetes_cluster.this.id }
output "name"       { value = azurerm_kubernetes_cluster.this.name }
output "kubelet_id" { value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id }
