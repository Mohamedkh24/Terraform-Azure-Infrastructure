## Public Load Balancer for Windows Server VMs

# Public IP for the WS-VMs load balancer
resource "azurerm_public_ip" "LB-PIP" {
  name = "LB-PIP"
  location = var.location
  resource_group_name = var.RG-name
  allocation_method = "Static"
  sku = "Standard"
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}
# Creating the Public Load Balancer
resource "azurerm_lb" "Pub-LB" {
  name = "Pub-LB"
  location = var.location
  resource_group_name = var.RG-name
  sku = "Standard"
  
  frontend_ip_configuration {
    name = "PubFrontEnd"
    public_ip_address_id = azurerm_public_ip.LB-PIP.id
  }
  depends_on = [ azurerm_public_ip.LB-PIP ]
  provisioner "local-exec" {
    command = "echo 'Load Balancer Public IP: ${azurerm_public_ip.LB-PIP.ip_address }' >> output.txt"
  }
}
# Backend Address pool
resource "azurerm_lb_backend_address_pool" "backend-pool" {
  name = "BackendPool"
  loadbalancer_id = azurerm_lb.Pub-LB.id
}
# Health Probe for HTTP on port 80
resource "azurerm_lb_probe" "http_health_probe" {
  name = "Http-Probe"
  loadbalancer_id = azurerm_lb.Pub-LB.id
  protocol = "Http"
  port = 80
  request_path = "/"
  interval_in_seconds = 5
  number_of_probes = 2
}
# Load Balancer Rule to forward HTTP traffic
resource "azurerm_lb_rule" "http_lb_rule" {
  name = "HTTP-Rule"
  loadbalancer_id = azurerm_lb.Pub-LB.id
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = "PubFrontEnd"
  probe_id = azurerm_lb_probe.http_health_probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend-pool.id]
}
# Associate the WS-VMs' NICs to the Backend Pool
# Associate WS-VM1's Nic
resource "azurerm_network_interface_backend_address_pool_association" "vm1-assoc" {
  network_interface_id = azurerm_network_interface.WVM1-nic.id
  ip_configuration_name = "vm1config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
}
# Associate WS-VM2's Nic
resource "azurerm_network_interface_backend_address_pool_association" "vm2-assoc" {
  network_interface_id = azurerm_network_interface.WVM2-nic.id
  ip_configuration_name = "vm2config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
}
#  --------------------------------------------------------------------------------
## Private Load Balancer for Linux Server VMs

# Creating Private Load balancer
resource "azurerm_lb" "Priv-LB" {
  name = "Priv-LB"
  location = var.location
  resource_group_name = var.RG-name
  sku = "Standard"

  frontend_ip_configuration {
    name = "PrivFrontEnd"
    subnet_id = azurerm_subnet.Sub-2.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_subnet.Sub-2 , azurerm_linux_virtual_machine.LS-VM1 , azurerm_linux_virtual_machine.LS-VM2]
  
  provisioner "local-exec" {
    command = "echo 'Private Load Balancer IP: ${azurerm_lb.Priv-LB.private_ip_address}' >> output.txt"
  }
}
# Backend Address pool
resource "azurerm_lb_backend_address_pool" "backend-pool2" {
  name = "BackendPool2"
  loadbalancer_id = azurerm_lb.Priv-LB.id
}
# Health Probe for HTTP on port 80
resource "azurerm_lb_probe" "http_HProbe" {
  name = "Http-probe2"
  loadbalancer_id = azurerm_lb.Priv-LB.id
  protocol = "Http"
  port = 80
  request_path = "/"
  interval_in_seconds = 5
  number_of_probes = 2
}
# Load Balancer Rule to forward HTTP traffic
resource "azurerm_lb_rule" "privLB-http-rule" {
  name = "Priv-HTTP-Rule"
  loadbalancer_id = azurerm_lb.Priv-LB.id
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  frontend_ip_configuration_name = "PrivFrontEnd"
  probe_id = azurerm_lb_probe.http_HProbe.id
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.backend-pool2.id ]
}
# Associate LS-VM1's Nic
resource "azurerm_network_interface_backend_address_pool_association" "Lnvm1-assoc" {
  network_interface_id = azurerm_network_interface.LnxVM1-nic.id
  ip_configuration_name = "lnvm1config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool2.id
}
# Associate LS-VM2's Nic
resource "azurerm_network_interface_backend_address_pool_association" "Lnvm2-assoc" {
  network_interface_id = azurerm_network_interface.LnxVM2-nic.id
  ip_configuration_name = "lnvm2config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool2.id
}