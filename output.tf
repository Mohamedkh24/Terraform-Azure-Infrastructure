output "WS-VM1-PIP" {
  value = azurerm_public_ip.vm1-pip.ip_address
}

output "Pub-LB-IP" {
  value = azurerm_public_ip.LB-PIP.ip_address
}

output "Priv-LB-IP" {
  value = azurerm_lb.Priv-LB.private_ip_address
}
output "Lnx-VM1-ip" {
  value = azurerm_linux_virtual_machine.LS-VM1.private_ip_address
}

output "Lnx-VM2-ip" {
  value = azurerm_linux_virtual_machine.LS-VM2.private_ip_address
}

# Storage Account (File Share) Outputs
output "FileShare-name" {
  value = azurerm_storage_share.premiumfileshare.name
}

# DB name output
output "SQLDataBase-name" {
  value = azurerm_mssql_database.sql-db.name
}