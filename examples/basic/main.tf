terraform {
  required_version = ">= 1.7"
}

module "datadog_integration" {
  source = "../.."

  subscription_id = "b0421966-9fd8-4a7f-a211-16c717313cb8"

  tenant_root_management_group_name = "myRootManagementGroup"

  datadog_teams = {
    tla-mce = {
      description = "Contoso Engineering"
      name        = "CTS ENG"
    }
  }

  saml_autocreate_users_domains = [
    "contoso.com"
  ]

  saml_autocreate_access_role = "ro"

  datadog_organization_name = "My Datadog Organization Name"

  datadog_integration_azure_config = {
    host_filters             = ""
    app_service_plan_filters = ""
    container_app_filters    = ""
    automute                 = false
    cspm_enabled             = false
    custom_metrics_enabled   = false
  }

  opsgenie_integration = [
    {
      name        = "tla-opsgenie"
      region      = "eu"
      secret_name = "keyvault-opsgenie-secret"
    }
  ]

  slack_integration_pager = {
    account_name     = "contoso"
    channel_name     = "#pager-channel"
    display_message  = true
    display_notified = true
    display_snapshot = true
    display_tags     = true
  }

  slack_integration_monitoring = {
    account_name     = "contoso"
    channel_name     = "#monitoring-channel"
    display_message  = true
    display_notified = true
    display_snapshot = true
    display_tags     = true
  }

  key_vault = {
    name                = "key-vault-name"
    resource_group_name = "key-vault-rg"
  }

  key_vault_secrets_names = {
    datadog_api_key_name = "datadog-api-key"
    datadog_app_key_name = "datadog-app-key"
  }

  saml_notification_email_addresses = ["user@contoso.com"]

  saml_certificate_end_date = "2028-05-07T00:00:00Z"
  saml_assigned_groups = [
    "sg-1",
    "sg-2"
  ]

  path_to_ddog_icon = "../../dd_icon_rgb.png"
}
