
resource "azurerm_virtual_network" "VNet-1" {
  name = var.VNet-name[0]
  location = var.location
  resource_group_name = var.RG-name
  address_space = var.VNet-Address-Space[0]
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}

resource "azurerm_virtual_network" "VNet-2" {
  name = var.VNet-name[1]
  location = var.location
  resource_group_name = var.RG-name
  address_space = var.VNet-Address-Space[1]
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}

resource "azurerm_virtual_network_peering" "peer1-2" {
  name = "peerHub-to-Spoke"
  resource_group_name = var.RG-name
  virtual_network_name = var.VNet-name[0]
  remote_virtual_network_id = azurerm_virtual_network.VNet-2.id
}

resource "azurerm_virtual_network_peering" "peer2-1" {
  name = "peerSpoke-to-Hub"
  resource_group_name = var.RG-name
  virtual_network_name = var.VNet-name[1]
  remote_virtual_network_id = azurerm_virtual_network.VNet-1.id
}