##### in order to allow private VMs to acccess internet we have to create a NAT Gateway
# Public IP Address for NAT Gateway
resource "azurerm_public_ip" "nat-pip" {
  name = "NAT-PIP"
  location = var.location
  resource_group_name = var.RG-name
  allocation_method = "Static"
  sku = "Standard"
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}
# NAT Gateway for internet access
resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "terraform-nat-gateway"
  location = var.location
  resource_group_name = var.RG-name
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}
# Associate Public IP with NAT GW
resource "azurerm_nat_gateway_public_ip_association" "Nat-PUb-assoc" {
  public_ip_address_id = azurerm_public_ip.nat-pip.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}
# Associate NAT GW with Private Subnet
resource "azurerm_subnet_nat_gateway_association" "nat-assoc" {
  subnet_id = azurerm_subnet.Sub-2.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
}

# Creating a Storage Account (Premium File Share)
resource "azurerm_storage_account" "lnxstorageacc12" {
  name = "lnxstorageacc"
  resource_group_name = var.RG-name
  location = var.location
  account_kind = "FileStorage"
  account_tier = "Premium"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Allow"
    bypass = [ "AzureServices" ]
    virtual_network_subnet_ids = [ azurerm_subnet.Sub-2.id ]
    ip_rules = [ "197.43.58.79" ]
  }
  depends_on = [ 
    azurerm_resource_group.Terraform-RG ,
    azurerm_virtual_network.VNet-1  ,
    azurerm_subnet.Sub-2
    ]
}
# Creating a Premium File Share in the Storage Account
resource "azurerm_storage_share" "premiumfileshare" {
  name = "premiumfileshare"
  storage_account_name = azurerm_storage_account.lnxstorageacc12.name
  enabled_protocol = "NFS"
  quota = 100            # means 100GB
  depends_on = [ azurerm_storage_account.lnxstorageacc12 ]
}

# Creating Linux Server VM-1
resource "azurerm_network_interface" "LnxVM1-nic" {
  name = "LnxVM1-nic"
  location = var.location
  resource_group_name = var.RG-name
  ip_configuration {
    name = "lnvm1config"
    subnet_id = azurerm_subnet.Sub-2.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_network_security_group.NSG-L ]
}
resource "azurerm_network_interface_security_group_association" "nsg-lnvm1" {
  network_security_group_id = azurerm_network_security_group.NSG-L.id
  network_interface_id = azurerm_network_interface.LnxVM1-nic.id
  depends_on = [
    azurerm_network_interface.LnxVM1-nic ,
    azurerm_network_security_group.NSG-L
   ]
}
resource "azurerm_linux_virtual_machine" "LS-VM1" {
  name = "LS-VM1"
  resource_group_name = var.RG-name
  location = var.location
  size = var.VM1-size
  zone = "1"
  network_interface_ids = [ azurerm_network_interface.LnxVM1-nic.id ]
  admin_username = "mk"
  admin_password = "Mk@123456"
   disable_password_authentication = false
   custom_data = base64encode(data.template_file.script_lnx_vm1.rendered)

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  provisioner "local-exec" {
    command = "echo 'Linux VM-1 IP: ${azurerm_linux_virtual_machine.LS-VM1.private_ip_address}' >> output.txt"
  }
  depends_on = [ azurerm_storage_account.lnxstorageacc12 ]
}

# Creating Linux Server VM-2
resource "azurerm_network_interface" "LnxVM2-nic" {
  name = "LnxVM2-nic"
  location = var.location
  resource_group_name = var.RG-name
  ip_configuration {
    name = "lnvm2config"
    subnet_id = azurerm_subnet.Sub-2.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_network_security_group.NSG-L ]
}
resource "azurerm_network_interface_security_group_association" "nsg-lnvm2" {
  network_security_group_id = azurerm_network_security_group.NSG-L.id
  network_interface_id = azurerm_network_interface.LnxVM2-nic.id
  depends_on = [
    azurerm_network_interface.LnxVM2-nic ,
    azurerm_network_security_group.NSG-L
   ]
}
resource "azurerm_linux_virtual_machine" "LS-VM2" {
  name = "LS-VM2"
  resource_group_name = var.RG-name
  location = var.location
  size = var.VM2-size
  zone = "3"
  network_interface_ids = [ azurerm_network_interface.LnxVM2-nic.id ]
  admin_username = "mk"
  admin_password = "Mk@123456"
  disable_password_authentication = false
  custom_data = base64encode(data.template_file.script_lnx_vm2.rendered)
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  provisioner "local-exec" {
    command = "echo 'Linux VM-2 IP: ${azurerm_linux_virtual_machine.LS-VM2.private_ip_address}' >> output.txt"
  }
  depends_on = [ azurerm_storage_account.lnxstorageacc12 ]
}
