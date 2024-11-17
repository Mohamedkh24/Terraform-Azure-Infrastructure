# Creating the SQL Server
resource "azurerm_mssql_server" "sql-server" {
  name = "sql-server-tf"
  resource_group_name = var.RG-name
  location = var.location
  version = "12.0"
  administrator_login = "mkadmin"
  administrator_login_password = "Mk@12345"
  depends_on = [ azurerm_resource_group.Terraform-RG ]
}

# Creating the SQL DataBase
resource "azurerm_mssql_database" "sql-db" {
  name = "sql-database-tf"
  server_id = azurerm_mssql_server.sql-server.id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb = 5
  sku_name = "GP_Gen5_2"
  zone_redundant = false
  depends_on = [ azurerm_mssql_server.sql-server ]
}

# Creating a firewall rule
resource "azurerm_mssql_firewall_rule" "allow_az_ips" {
  name = "AllowAzureIps"
  server_id = azurerm_mssql_server.sql-server.id
  start_ip_address = "0.0.0.0"
  end_ip_address = "0.0.0.0"
  depends_on = [ azurerm_mssql_server.sql-server ]
}
