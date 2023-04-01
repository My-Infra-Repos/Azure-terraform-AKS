resource "azurerm_log_analytics_workspace" "aks_monitoring" {
  name                = var.loganalytics_name
  location            = var.location
  resource_group_name = data.terraform_remote_state.rg.outputs.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
}

resource "azurerm_log_analytics_solution" "aks_monitoring_solution" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = data.terraform_remote_state.rg.outputs.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_monitoring.id
  workspace_name        = azurerm_log_analytics_workspace.aks_monitoring.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_log_analytics_solution" "agw_monitoring_solution" {
  solution_name         = "AzureAppGatewayAnalytics"
  location              = var.location
  resource_group_name   = data.terraform_remote_state.rg.outputs.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks_monitoring.id
  workspace_name        = azurerm_log_analytics_workspace.aks_monitoring.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureAppGatewayAnalytics"
  }
}