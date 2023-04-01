// resource "kubernetes_service_account" "tiller_sa" {
//   metadata {
//     name      = "tiller"
//     namespace = "kube-system"
//   }
// }

// resource "kubernetes_cluster_role_binding" "tiller_sa_cluster_admin_rb" {
//   metadata {
//     name = "tiller-cluster-role"
//   }
//   role_ref {
//     kind      = "ClusterRole"
//     name      = "cluster-admin"
//     api_group = "rbac.authorization.k8s.io"
//   }
//   subject {
//     kind      = "ServiceAccount"
//     name      = "${kubernetes_service_account.tiller_sa.metadata.0.name}"
//     namespace = "kube-system"
//     api_group = ""
//   }
// }

# Install helm package for application gateway
resource "helm_release" "agic" {
  name       = "agic"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
  chart      = "ingress-azure"
  namespace  = "kube-system" # todo: pass proper name from aks module
  version    = var.helm_agic_version
  timeout    = 1200

  set {
    name  = "appgw.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name  = "appgw.resourceGroup"
    value = data.terraform_remote_state.rg.outputs.name
  }

  set {
    name  = "appgw.name"
    // value = azurerm_application_gateway.appgateway.name
    value = data.terraform_remote_state.appgateway.outputs.appgw_name
  }

  set {
    name  = "armAuth.identityResourceID"
    // value = azurerm_user_assigned_identity.agidentity.id
    value = data.terraform_remote_state.appgateway.outputs.azurerm_user_assigned_identity
  }

  set {
    name  = "armAuth.identityClientID"
    // value = azurerm_user_assigned_identity.agidentity.client_id
    value = data.terraform_remote_state.appgateway.outputs.azurerm_user_assigned_client_identity
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "appgw.shared"
    value = false
  }

  set {
    name  = "appgw.usePrivateIP"
    value = false
  }

  set {
    name  = "rbac.enabled"
    value = true
  }

  set {
    name  = "verbosityLevel"
    value = 3
  }


}