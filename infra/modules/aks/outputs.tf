output "kubelet_object_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "kubelet_client_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}
