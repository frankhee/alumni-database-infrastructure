output "id" {
  value = data.azurerm_resource_group.example.id
}

output "az_resource_group_name" {
  value = azurerm_resource_group.default.name
}