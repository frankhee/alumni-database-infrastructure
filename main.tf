resource "azurerm_resource_group" "default" {
  name     = var.random
  location = "West US 2"

  tags = {
    environment = "dev"
    project     = local.az_tag
  }
}