# terraform-azure-mcaf-datadog-integrations

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.53.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4 |
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | ~> 3.59 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.53.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4 |
| <a name="provider_datadog"></a> [datadog](#provider\_datadog) | ~> 3.59 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.group_assignments](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application.datadog_saml_auth_application_registration](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_identifier_uri.datadog_saml_auth_application_identifier_uri](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_identifier_uri) | resource |
| [azuread_application_password.app_password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_claims_mapping_policy.datadog_saml_auth_claims_mapping_policy](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/claims_mapping_policy) | resource |
| [azuread_service_principal.datadog_saml_auth_enterprise_application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_claims_mapping_policy_assignment.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_claims_mapping_policy_assignment) | resource |
| [azuread_service_principal_token_signing_certificate.saml_signing_cert](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_token_signing_certificate) | resource |
| [azurerm_role_assignment.datadog](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [datadog_integration_azure.this](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_azure) | resource |
| [datadog_integration_opsgenie_service_object.opsgenie_integration](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_opsgenie_service_object) | resource |
| [datadog_integration_slack_channel.slack_integration_monitoring](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_slack_channel) | resource |
| [datadog_integration_slack_channel.slack_integration_pager](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_slack_channel) | resource |
| [datadog_organization_settings.organization](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/organization_settings) | resource |
| [datadog_role.enhanced_reader](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/role) | resource |
| [datadog_team.teams](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/team) | resource |
| [time_rotating.rotation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [azuread_group.sso_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.datadog_api_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.datadog_app_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.opsgenie_api_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_management_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [datadog_permissions.current](https://registry.terraform.io/providers/datadog/datadog/latest/docs/data-sources/permissions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datadog_integration_azure_config"></a> [datadog\_integration\_azure\_config](#input\_datadog\_integration\_azure\_config) | Datadog Azure Integration config | <pre>object({<br/>    host_filters             = string<br/>    app_service_plan_filters = string<br/>    container_app_filters    = string<br/>    automute                 = bool<br/>    cspm_enabled             = bool<br/>    custom_metrics_enabled   = bool<br/>  })</pre> | n/a | yes |
| <a name="input_datadog_organization_name"></a> [datadog\_organization\_name](#input\_datadog\_organization\_name) | The Datadog organization name | `string` | n/a | yes |
| <a name="input_datadog_teams"></a> [datadog\_teams](#input\_datadog\_teams) | Datadog team configuration | <pre>map(<br/>    object({<br/>      description = string<br/>      name        = string<br/>    })<br/>  )</pre> | n/a | yes |
| <a name="input_key_vault"></a> [key\_vault](#input\_key\_vault) | The properties of the Key Vault to be used to store secrets | <pre>object({<br/>    name                = string<br/>    resource_group_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_key_vault_secrets_names"></a> [key\_vault\_secrets\_names](#input\_key\_vault\_secrets\_names) | The names of the secrets stored in the Key Vault | <pre>object({<br/>    datadog_api_key_name  = string<br/>    datadog_app_key_name  = string<br/>  })</pre> | n/a | yes |
| <a name="input_opsgenie_integration"></a> [opsgenie\_integration](#input\_opsgenie\_integration) | OpsGenie integration configuration | <pre>list(object({<br/>    name        = string<br/>    region      = string<br/>    secret_name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_saml_assigned_groups"></a> [saml\_assigned\_groups](#input\_saml\_assigned\_groups) | List of Azure Entra ID group display names to assign to the Enterprise Application | `list(string)` | n/a | yes |
| <a name="input_saml_autocreate_users_domains"></a> [saml\_autocreate\_users\_domains](#input\_saml\_autocreate\_users\_domains) | List of domains where the SAML automated user creation is enabled | `list(string)` | n/a | yes |
| <a name="input_saml_certificate_end_date"></a> [saml\_certificate\_end\_date](#input\_saml\_certificate\_end\_date) | End date for SAML SSO autogenerated certificate (UTC ISO 8601 format, max 3 years from now) | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure subscription id | `string` | n/a | yes |
| <a name="input_tenant_root_management_group_name"></a> [tenant\_root\_management\_group\_name](#input\_tenant\_root\_management\_group\_name) | Tenant root Azure management group name | `string` | n/a | yes |
| <a name="input_datadog_site_name"></a> [datadog\_site\_name](#input\_datadog\_site\_name) | Datadog site name | `string` | `"datadoghq.eu"` | no |
| <a name="input_path_to_ddog_icon"></a> [path\_to\_ddog\_icon](#input\_path\_to\_ddog\_icon) | Path to the Datadog icon file | `string` | `"/dd_icon_rgb.png"` | no |
| <a name="input_saml_autocreate_access_role"></a> [saml\_autocreate\_access\_role](#input\_saml\_autocreate\_access\_role) | n/a | `string` | `"ro"` | no |
| <a name="input_saml_notification_email_addresses"></a> [saml\_notification\_email\_addresses](#input\_saml\_notification\_email\_addresses) | List of email addresses to receive SAML certificate expiry notifications. | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_slack_integration_monitoring"></a> [slack\_integration\_monitoring](#input\_slack\_integration\_monitoring) | Slack integration configuration for Monitoring | <pre>object({<br/>    account_name     = string<br/>    channel_name     = string<br/>    display_message  = bool<br/>    display_notified = bool<br/>    display_snapshot = bool<br/>    display_tags     = bool<br/>  })</pre> | `null` | no |
| <a name="input_slack_integration_pager"></a> [slack\_integration\_pager](#input\_slack\_integration\_pager) | Slack integration configuration for Pager alerts | <pre>object({<br/>    account_name     = string<br/>    channel_name     = string<br/>    display_message  = bool<br/>    display_notified = bool<br/>    display_snapshot = bool<br/>    display_tags     = bool<br/>  })</pre> | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## License

**Copyright:** Schuberg Philis

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```