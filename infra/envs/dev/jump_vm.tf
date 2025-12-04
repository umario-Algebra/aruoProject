# Jump VM – data sources to grab existing RG + subnet
data "azurerm_resource_group" "rg_jump" {
  name = "rg-aruop-dev-net"
}

data "azurerm_subnet" "snet_jump" {
  name                 = "snet-jump"
  virtual_network_name = "vnet-aruop-dev-jump"
  resource_group_name  = data.azurerm_resource_group.rg_jump.name
}

resource "azurerm_public_ip" "jump" {
  name                = "pip-aruop-dev-jump01"
  location            = data.azurerm_resource_group.rg_jump.location
  resource_group_name = data.azurerm_resource_group.rg_jump.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    costCenter = "000"
    env        = "dev"
    owner      = "umario"
    project    = "aruo"
    student    = "umario@algebra.hr"
    university = "Algebra"
  }
}

resource "azurerm_network_interface" "jump" {
  name                = "nic-aruop-dev-jump01"
  location            = data.azurerm_resource_group.rg_jump.location
  resource_group_name = data.azurerm_resource_group.rg_jump.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.snet_jump.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jump.id
  }

  tags = {
    costCenter = "000"
    env        = "dev"
    owner      = "umario"
    project    = "aruo"
    student    = "umario@algebra.hr"
    university = "Algebra"
  }
}

resource "azurerm_windows_virtual_machine" "jump" {
  name                = "vm-aruop-dev-jump01"
  computer_name       = "aruopjump01"
  location            = data.azurerm_resource_group.rg_jump.location
  resource_group_name = data.azurerm_resource_group.rg_jump.name
  size                = "Standard_B2ms"

  admin_username = var.jump_admin_username
  admin_password = var.jump_admin_password

  network_interface_ids = [
    azurerm_network_interface.jump.id
  ]

  os_disk {
    name                 = "osdisk-aruop-dev-jump01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    costCenter = "000"
    env        = "dev"
    owner      = "umario"
    project    = "aruo"
    student    = "umario@algebra.hr"
    university = "Algebra"
  }
}
