# Creating the Private EndPoint On the Subnet (Spoke VNet)
resource "azurerm_private_endpoint" "priv-endpoint" {
  name = "db-priv-endpoint"
  location = var.location
  resource_group_name = var.RG-name
  subnet_id = azurerm_subnet.DB-Snet.id

  private_service_connection {
    name = "priv-sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql-server.id
    subresource_names = [ "sqlServer" ]
    is_manual_connection = false
  }
  depends_on = [ azurerm_mssql_server.sql-server , 
                 azurerm_resource_group.Terraform-RG ,
                 azurerm_subnet.DB-Snet
               ]
}

# Creating the Private DNS Zone
resource "azurerm_private_dns_zone" "dns-zone" {
  name = "privatelink.database.windows.net"
  resource_group_name = var.RG-name
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}
# Creating a link between the Hub-VNet and the Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "hubvnet-link" {
  name = "hub-vnet-link"
  resource_group_name = var.RG-name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id = azurerm_virtual_network.VNet-1.id

  depends_on = [ 
                 azurerm_resource_group.Terraform-RG , 
                 azurerm_private_dns_zone.dns-zone ,  
                 azurerm_virtual_network.VNet-1
               ]
}
# Creating Private DNS record
resource "azurerm_private_dns_a_record" "sql-dns-record" {
  name = azurerm_mssql_server.sql-server.name
  zone_name = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = var.RG-name
  ttl = 300
  records = [ azurerm_private_endpoint.priv-endpoint.private_service_connection[0].private_ip_address ]
  depends_on = [ 
                 azurerm_mssql_server.sql-server ,
                 azurerm_private_dns_zone.dns-zone ,
                 azurerm_resource_group.Terraform-RG 
               ]
}
