// resource "azurerm_subnet" "appgwsubnet" {
//   name                 = "subnet-${var.app_name}_appgw"
//   resource_group_name  = data.terraform_remote_state.rg.outputs.name
//   virtual_network_name = data.terraform_remote_state.vnet.outputs.name
//   address_prefixes     = [var.address_space]
// }


# Subnet permission
resource "azurerm_role_assignment" "aks_subnet_rbac" {
  // scope                = azurerm_subnet.aks_subnet.id
  scope = data.terraform_remote_state.akssubnet.outputs.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

# Allow the AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull_role" {
  // scope                = var.acr_id
  scope                = data.terraform_remote_state.acr.outputs.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

# Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.app_name}"
  location            = var.location
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  dns_prefix          = "aks-${var.app_name}"
  kubernetes_version  = var.kubernetes_version
  // 2nd Phase
  //  ingress_application_gateway {

  //   gateway_id = data.terraform_remote_state.apg.outputs.appgw_id
  // }
  // enable_aci_connector_linux      = true
  // aci_connector_linux_subnet_name = data.terraform_remote_state.akssubnet.outputs.aci_aks_subnet_id

//  aci_connector_linux {
//       enabled = true
//       subnet_name =  data.terraform_remote_state.akssubnet.outputs.aci_aks_subnet_id
//     }

  default_node_pool {
    type                = "VirtualMachineScaleSets"
    name                = "default"
    node_count          = var.node_pool_min_count
    vm_size             = var.vm_size_node_pool
    os_disk_size_gb     = 30
    // vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    vnet_subnet_id      = data.terraform_remote_state.akssubnet.outputs.aks_subnet_id
    enable_auto_scaling = true
    max_count           = var.node_pool_max_count
    min_count           = var.node_pool_min_count
  }

  //  ingress_application_gateway {
  //   subnet_id = azurerm_subnet.appgwsubnet.id
  //   // subnet_cidr = "10.2.4.0/28"
  //   gateway_name = "prmag-appgw"
  //   gateway_ip_configuration {
  //   name      = "appgw-ip-config"
  //   subnet_id = azurerm_subnet.appgwsubnet.id
  // }

  // frontend_port {
  //   name = local.frontend_port_name
  //   port = 80
  // }

  // frontend_ip_configuration {
  //   name                 = local.frontend_ip_configuration_name
    // public_ip_address_id = azurerm_public_ip.public_ip.id
  // }
  // }

  network_profile {
    network_plugin = "azure"
    // network_policy = "calico"
    network_policy     = "azure"
    outbound_type      = "userAssignedNATGateway"
    // inbound_type      = "userAssignedNATGateway"
    nat_gateway_profile {
      idle_timeout_in_minutes = 4
    }
  }

// log_analytics_workspace_id = data.terraform_remote_state.la.outputs.id

  // addon_profile {
  //   aci_connector_linux { enabled = false }
  //   azure_policy { enabled = false }
  //   http_application_routing { enabled = false }
  //   kube_dashboard { enabled = false }
    oms_agent {
      // enabled                    = true
      // log_analytics_workspace_id = var.log_analytics_id
      log_analytics_workspace_id = data.terraform_remote_state.la.outputs.id
    }
  // }

  // role_based_access_control {
  //   enabled = var.kubernetes_cluster_rbac_enabled

  //   azure_active_directory {
  //     managed                = true
  //     admin_group_object_ids = [var.aks_admins_group_object_id]
  //   }
  // }
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids =  [var.aks_admins_group_object_id]
    azure_rbac_enabled     = true
  }

  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      network_profile[0].nat_gateway_profile
    ]
  }

}

// resource "azurerm_role_assignment" "aks_ingressid_contributor_on_agw" {
//   // scope                            = azurerm_application_gateway.network.id
//   scope                            = data.terraform_remote_state.apg.outputs.appgw_id
//   role_definition_name             = "Contributor"
//   principal_id                     = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
//   // depends_on                       = [azurerm_application_gateway.network]
//   skip_service_principal_aad_check = true
// }

// resource "azurerm_role_assignment" "aks_ingressid_contributor_on_uami" {
//   // scope                            = azurerm_user_assigned_identity.identity_uami.id
//   scope                            = data.terraform_remote_state.apg.outputs.uami_id
//   role_definition_name             = "Contributor"
//   principal_id                     = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
//   // depends_on                       = [azurerm_application_gateway.network]
//   skip_service_principal_aad_check = true
// }

// resource "azurerm_role_assignment" "uami_contributor_on_agw" {
//   scope                            = data.terraform_remote_state.apg.outputs.appgw_id
//   role_definition_name             = "Contributor"
//   // principal_id                     = data.terraform_remote_state.apg.outputs.principal_id
//   principal_id                     = data.terraform_remote_state.apg.outputs.principal_id
//   // depends_on                       = [azurerm_application_gateway.network]
//   skip_service_principal_aad_check = true
// }
