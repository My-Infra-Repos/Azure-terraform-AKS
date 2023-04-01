

output "aks_subnet" {
  value = azurerm_subnet.aks_subnet.name
  description = "AKS Subnet object"
}


output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
  description = "AKS Subnet ID object"
}



// output "aci_aks_subnet" {
//   value = azurerm_subnet.aci_aks_subnet.name
//   description = "AKS Subnet object"
// }


// output "aci_aks_subnet_id" {
//   value = azurerm_subnet.aci_aks_subnet.id
//   description = "AKS Subnet ID object"
// }