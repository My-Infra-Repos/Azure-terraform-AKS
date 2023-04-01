output "kubelet_identity" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  description = "The kubelet identity."
}
// output "cluster_identity" {
//   description = "The `azurerm_kubernetes_cluster`'s `identity` block."
//   value       = try(azurerm_kubernetes_cluster.main.identity[0], null)
// }
output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
  description = "Name of the AKS cluster"
}

output "aks_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0
  sensitive =  true
  description = "AKS Config object"
}

output "aks_admin_config" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0
  sensitive =  true
  description = "AKS Admin Config object"
}


// output "aks_subnet" {
//   value = azurerm_subnet.aks_subnet.name
//   description = "AKS Subnet object"
// }


// output "aks_subnet_id" {
//   value = azurerm_subnet.aks_subnet.id
//   description = "AKS Subnet ID object"
// }

