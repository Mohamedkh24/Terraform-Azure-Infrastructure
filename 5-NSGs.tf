# Network Security Group for WS-VMs (allow RDP-HTTP-HTTPs) --> Shared
resource "azurerm_network_security_group" "NSG-W" {
  name = var.nsg_name[0]
  location = var.location
  resource_group_name = var.RG-name
  dynamic "security_rule" {
    for_each = var.allowed_ports1
    content {
      name                       = "Allow-${security_rule.key}"
      priority                   = 100+index(keys(var.allowed_ports1), security_rule.key)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(security_rule.value)
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}

# Network Security Group for Lnx-VMs (allow SSH-HTTP-HTTPs) --> Shared
resource "azurerm_network_security_group" "NSG-L" {
  name = var.nsg_name[1]
  location = var.location
  resource_group_name = var.RG-name
  dynamic "security_rule" {
    for_each = var.allowed_ports2
    content {
      name                       = "Allow-${security_rule.key}"
      priority                   = 100+index(keys(var.allowed_ports2), security_rule.key)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = tostring(security_rule.value)
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}