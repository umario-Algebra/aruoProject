locals {
  prefix = "aruop-${var.env}"
  names = {
    rg_core   = "rg-${local.prefix}-core"
    rg_net    = "rg-${local.prefix}-net"
    rg_sec    = "rg-${local.prefix}-sec"

    vnet_core = "vnet-${local.prefix}-core"
    vnet_jump = "vnet-${local.prefix}-jump"
    snet_aks  = "snet-aks"
    snet_appg = "snet-appgw"
    snet_func = "snet-func"
    snet_pg   = "snet-pg"
    snet_jump = "snet-jump"

    la        = "law-${local.prefix}-01"
  }
}
