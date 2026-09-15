data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

data "datadog_permissions" "current" {
  include_restricted = true
}

data "azuread_group" "sso_groups" {
  for_each     = var.saml_assigned_groups
  display_name = each.key
}
