resource "azuread_application" "application" {
  display_name = "datadog-monitoring"
  owners       = var.owners
  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["User.ReadBasic.All"]
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "spn" {
  client_id                    = azuread_application.application.client_id
  owners                       = azuread_application.application.owners
  app_role_assignment_required = false

  tags = [
    "AppServiceIntegratedApp",
    "HideApp",
    "WindowsAzureActiveDirectoryIntegratedApp",
  ]
}

resource "time_rotating" "rotation" {
  rotation_days = 365
}

resource "azuread_application_password" "app_password" {
  display_name   = "datadog-monitoring-app-password"
  application_id = azuread_application.application.id
  rotate_when_changed = {
    rotation = time_rotating.rotation.id
  }
}

resource "azurerm_role_assignment" "datadog" {
  scope                = var.datadog_integration_azure_config.monitored_scope
  role_definition_name = "Monitoring Reader"
  principal_id         = azuread_service_principal.spn.object_id
}

resource "datadog_integration_azure" "this" {
  tenant_name                 = var.datadog_integration_azure_config.tenant_name
  client_id                   = azuread_application.application.client_id
  client_secret               = azuread_application_password.app_password.value
  host_filters                = join(",", var.datadog_integration_azure_config.host_filters)
  app_service_plan_filters    = join(",", var.datadog_integration_azure_config.app_service_plan_filters)
  container_app_filters       = join(",", var.datadog_integration_azure_config.container_app_filters)
  automute                    = var.datadog_integration_azure_config.automute
  cspm_enabled                = var.datadog_integration_azure_config.cspm_enabled
  custom_metrics_enabled      = var.datadog_integration_azure_config.custom_metrics_enabled
  metrics_enabled             = true
  metrics_enabled_default     = true
  usage_metrics_enabled       = true
  resource_collection_enabled = true
}
