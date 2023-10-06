# Subnet
resource "azurerm_subnet" "appgw" {
  name                 = "subnet-${var.app_name}_appgw"
  resource_group_name  = data.terraform_remote_state.rg.outputs.name
  virtual_network_name = data.terraform_remote_state.vnet.outputs.name
  address_prefixes     = [var.address_space]
}

# Create managed identity for application gateway
resource "azurerm_user_assigned_identity" "agidentity" {
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  location            = var.location
  name                = "id_${var.app_name}_appgw"
}

#
# Ingress controller
#
# The ingress controller requires the following permissions:
# - Reader on the resource group
# - Contributor on the App gateway
# - Managed Identity exampleerator on the user created identity
#

resource "azurerm_role_assignment" "appgwreader" {
  scope                = data.terraform_remote_state.rg.outputs.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agidentity.principal_id
}

resource "azurerm_role_assignment" "mi_operator_ag" {
  scope                = data.terraform_remote_state.rg.outputs.id
  role_definition_name = "Managed Identity exampleerator"
  principal_id         = azurerm_user_assigned_identity.agidentity.principal_id
}

resource "azurerm_role_assignment" "agic_contrib" {
  scope                = azurerm_application_gateway.appgateway.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agidentity.principal_id
}

resource "azurerm_role_assignment" "mi_operator_agic" {
  scope                = azurerm_user_assigned_identity.agidentity.id
  role_definition_name = "Managed Identity exampleerator"
  // principal_id         = var.aks_object_id
  principal_id         = data.terraform_remote_state.aks.outputs.kubelet_identity

}


# Application Gateway
locals {
  backend_address_pool_name      = "${data.terraform_remote_state.vnet.outputs.name}-beap"
  frontend_port_name             = "${data.terraform_remote_state.vnet.outputs.name}-feport"
  frontend_ip_configuration_name = "${data.terraform_remote_state.vnet.outputs.name}-feip"
  http_setting_name              = "${data.terraform_remote_state.vnet.outputs.name}-be-htst"
  http_listener_name             = "${data.terraform_remote_state.vnet.outputs.name}-httplstn"
  request_routing_rule_name      = "${data.terraform_remote_state.vnet.outputs.name}-rqrt"
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "publicip-${var.app_name}-aks"
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domain_name_label # Maps to <domain_name_label>.<region>.cloudapp.azure.com
}

# Application gateway
resource "azurerm_application_gateway" "appgateway" {
  name                = "appgw-${var.app_name}-aks"
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  location            = var.location
  
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.1"

    disabled_rule_group {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      rules           = [931130]
    }
    disabled_rule_group {
      rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
      rules = [
        941320,
        941130,
        941170,
        941100,
        941150,
      941160]
    }
    disabled_rule_group {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules = [
        942130,
        942200,
        942260,
        942430,
        942100,
        942370,
        942340,
        942450,
        942150,
        942410,
        942440,
      942390]
    }
    disabled_rule_group {
      rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
      rules           = [930110]
    }
  }

    sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

    autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  // sku {
  //   name     = "Standard_v2"
  //   tier     = "Standard_v2"
  //   //     name     = "Standard"
  //   // tier     = "Standard"
  //   capacity = 1
  // }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

    frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 1
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agidentity.id]
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      probe,
      identity,
      request_routing_rule,
      url_path_map,
      frontend_port,
      http_listener,
      redirect_configuration
    ]
  }
}

# Install helm package for application gateway
// resource "helm_release" "agic" {
//   name       = "agic"
//   repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
//   chart      = "ingress-azure"
//   namespace  = var.app_name # todo: pass proper name from aks module
//   version    = var.helm_agic_version
//   timeout    = 1800

//   set {
//     name  = "appgw.subscriptionId"
//     value = data.azurerm_subscription.current.subscription_id
//   }

//   set {
//     name  = "appgw.resourceGroup"
//     value = data.terraform_remote_state.rg.outputs.name
//   }

//   set {
//     name  = "appgw.name"
//     value = azurerm_application_gateway.appgateway.name
//   }

//   set {
//     name  = "armAuth.identityResourceID"
//     value = azurerm_user_assigned_identity.agidentity.id
//   }

//   set {
//     name  = "armAuth.identityClientID"
//     value = azurerm_user_assigned_identity.agidentity.client_id
//   }

//   set {
//     name  = "armAuth.type"
//     value = "aadPodIdentity"
//   }

//   set {
//     name  = "appgw.shared"
//     value = false
//   }

//   set {
//     name  = "appgw.usePrivateIP"
//     value = false
//   }

//   set {
//     name  = "rbac.enabled"
//     value = true
//   }

//   set {
//     name  = "verbosityLevel"
//     value = 3
//   }

//   depends_on = [
//     azurerm_application_gateway.appgateway,
//     azurerm_role_assignment.appgwreader,
//     azurerm_role_assignment.mi_operator_ag,
//     azurerm_role_assignment.agic_contrib,
//     azurerm_role_assignment.mi_operator_agic
//   ]
// }