resource "azurerm_resource_group" "Terraform-RG" {
  name = var.RG-name
  location = var.location
}