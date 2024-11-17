resource "azurerm_subnet" "Sub-1" {
  name = var.subnet-name[0]
  resource_group_name = var.RG-name
  virtual_network_name = var.VNet-name[0]
  address_prefixes = var.Sub-Prefix[0]
  depends_on = [ azurerm_virtual_network.VNet-1 ]
}

resource "azurerm_subnet" "Sub-2" {
  name = var.subnet-name[1]
  resource_group_name = var.RG-name
  virtual_network_name = var.VNet-name[0]
  address_prefixes = var.Sub-Prefix[1]
  service_endpoints = [ "Microsoft.Storage" ]
  depends_on = [ azurerm_virtual_network.VNet-1 ]
}

resource "azurerm_subnet" "DB-Snet" {
  name = var.subnet-name[2]
  resource_group_name = var.RG-name
  virtual_network_name = var.VNet-name[1]
  address_prefixes = var.Sub-Prefix[2]
  depends_on = [ azurerm_virtual_network.VNet-2 ]
}