output "snet_aks_id"    { value = azurerm_subnet.snet_aks.id }
output "snet_appgw_id"  { value = azurerm_subnet.snet_appgw.id }
output "snet_func_id"   { value = azurerm_subnet.snet_func.id }
output "snet_pg_id"     { value = azurerm_subnet.snet_pg.id }
output "snet_jump_id"   { value = azurerm_subnet.snet_jump.id }
output "core_vnet_id"   { value = azurerm_virtual_network.core.id }
