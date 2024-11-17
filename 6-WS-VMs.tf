# Creating a Public IP for Win-VM1
resource "azurerm_public_ip" "vm1-pip" {
  name = "VM1-PIP"
  location = var.location
  zones = ["1"]
  resource_group_name = var.RG-name
  allocation_method = "Static"
  sku = "Standard"
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}

# Creating Windows Server VM-1
resource "azurerm_network_interface" "WVM1-nic" {
  name = "WVM1-nic"
  location = var.location
  resource_group_name = var.RG-name
  ip_configuration {
    name = "vm1config"
    subnet_id = azurerm_subnet.Sub-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm1-pip.id
  }
  depends_on = [ azurerm_network_security_group.NSG-W ]
}
resource "azurerm_network_interface_security_group_association" "nsg-vm1" {
  network_security_group_id = azurerm_network_security_group.NSG-W.id
  network_interface_id = azurerm_network_interface.WVM1-nic.id
  depends_on = [
    azurerm_network_interface.WVM1-nic ,
    azurerm_network_security_group.NSG-W
   ]
}
resource "azurerm_windows_virtual_machine" "WS-VM1" {
  name                = "WS-VM1"
  resource_group_name = var.RG-name
  location            = var.location
  size                = var.VM1-size
  zone = "1"
  network_interface_ids = [ azurerm_network_interface.WVM1-nic.id ]
  admin_username = "mk"
  admin_password = "Mk@123456"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
  custom_data    = base64encode(data.template_file.script_iis_vm1.rendered)
  provisioner "local-exec" {
     command = "echo 'VM1 Public IP: ${azurerm_public_ip.vm1-pip.ip_address}' >> output.txt"
  }
  depends_on = [ azurerm_public_ip.vm1-pip , azurerm_network_interface_security_group_association.nsg-vm1 ]
}

# Creating Windows Server VM-2
resource "azurerm_network_interface" "WVM2-nic" {
  name = "WVM2-nic"
  location = var.location
  resource_group_name = var.RG-name
  ip_configuration {
    name = "vm2config"
    subnet_id = azurerm_subnet.Sub-1.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_network_security_group.NSG-W ]
}
resource "azurerm_network_interface_security_group_association" "nsg-vm2" {
  network_security_group_id = azurerm_network_security_group.NSG-W.id
  network_interface_id = azurerm_network_interface.WVM2-nic.id
  depends_on = [
    azurerm_network_interface.WVM2-nic ,
    azurerm_network_security_group.NSG-W
   ]
}
resource "azurerm_windows_virtual_machine" "WS-VM2" {
  name                = "WS-VM2"
  resource_group_name = var.RG-name
  location            = var.location
  size                = var.VM2-size
  zone = "3"
  network_interface_ids = [ azurerm_network_interface.WVM2-nic.id ]
  admin_username = "mk"
  admin_password = "Mk@123456"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
  custom_data    = base64encode(data.template_file.script_iis_vm2.rendered)
  depends_on = [ azurerm_network_interface_security_group_association.nsg-vm2 ]
}