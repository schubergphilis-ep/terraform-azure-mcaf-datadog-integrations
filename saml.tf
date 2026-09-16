resource "random_uuid" "saml_uuids" {
  for_each = toset(["oauth", "user", "group", "msiam"])
}

data "azuread_application_template" "datadog" {
  display_name = "Datadog"
}

resource "azuread_application_from_template" "datadog" {
  display_name = "Datadog"
  template_id  = data.azuread_application_template.datadog.template_id
}

resource "azuread_application_identifier_uri" "datadog_saml_auth_application_identifier_uri" {
  application_id = azuread_application_from_template.datadog.application_id
  identifier_uri = "https://app.${var.datadog_url}/account/saml/metadata.xml"
}

# resource "azuread_service_principal" "datadog_saml_auth_enterprise_application" {
#   client_id                     = azuread_application_from_template.datadog.
#   app_role_assignment_required  = true
#   login_url                     = "https://app.${var.datadog_url}/account/login/id/${datadog_organization_settings.organization.id}"
#   preferred_single_sign_on_mode = "saml"
#   notification_email_addresses  = var.saml_notification_email_addresses
#   feature_tags {
#     enterprise            = true
#     custom_single_sign_on = true
#   }
# }

resource "azuread_claims_mapping_policy" "datadog_saml_auth_claims_mapping_policy" {
  display_name = "datadog-saml-auth-claims-mapping-policy"
  definition = [jsonencode({
    ClaimsMappingPolicy = {
      Version              = 1
      IncludeBasicClaimSet = false
      ClaimsSchema = [
        # Required claim: email address
        {
          Source        = "user"
          ID            = "mail"
          SamlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        },

        # Name ID: user.userprincipalname with email format
        {
          Source                   = "user"
          ID                       = "userPrincipalName"
          SamlClaimType            = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
          SamlNameIdentifierFormat = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        },

        # Additional claim: groups
        {
          Source        = "user"
          ID            = "groups"
          SamlClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
        },

        # Additional claim: given name
        {
          Source        = "user"
          ID            = "givenName"
          SamlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
        },

        # Additional claim: name
        {
          Source        = "user"
          ID            = "userPrincipalName"
          SamlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
        },

        # Additional claim: surname
        {
          Source        = "user"
          ID            = "surname"
          SamlClaimType = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
        }
      ]
    }
  })]
}

resource "azuread_service_principal_claims_mapping_policy_assignment" "app" {
  claims_mapping_policy_id = azuread_claims_mapping_policy.datadog_saml_auth_claims_mapping_policy.id
  service_principal_id     = azuread_application_from_template.datadog.service_principal_id
}

resource "time_rotating" "certificate_expiration" {
  rotation_years = 3
}

# Generate and assign a SAML token signing certificate (End Date Validity is 3 years max)
resource "azuread_service_principal_token_signing_certificate" "saml_signing_cert" {
  service_principal_id = azuread_application_from_template.datadog.service_principal_id
  display_name         = "CN=DataDog SAML SSO Certificate"
  end_date             = time_rotating.certificate_expiration.rotation_rfc3339
}

resource "azuread_service_principal" "datadog" {
  use_existing = true
  client_id    = azuread_application_from_template.datadog.application_id
  preferred_single_sign_on_mode = "saml"

  group_membership_claims = ["ApplicationGroup"]
  app_role_assignment_required  = true
  login_url                     = "https://app.${var.datadog_url}/account/login/id/${datadog_organization_settings.organization.id}"
  notification_email_addresses  = var.saml_notification_email_addresses
  feature_tags {
    enterprise            = true
    custom_single_sign_on = true
  }
}

# Assign Entra ID Groups to the Enterprise Application
resource "azuread_app_role_assignment" "group_assignments" {
  for_each = data.azuread_group.sso_groups

  principal_object_id = each.value.object_id
  resource_object_id  = azuread_application_from_template.datadog.service_principal_object_id

  app_role_id = one([
    for role in azuread_service_principal.datadog.app_roles:
    role.id if role.display_name == "User"
  ])
}

resource "time_sleep" "metadata_availability" {
  create_duration = "60s"
  depends_on = [azuread_application_from_template.datadog.service_principal_id]
}

data "http" "datadog_idp_metadata" {
  url = "https://login.microsoftonline.com/${var.datadog_integration_azure_config.tenant_name}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_service_principal.datadog.client_id}"

  request_headers = {
    Accept = "application/xml"
  }
  
  depends_on = [time_sleep.metadata_availability]
}

locals {
  cleaned_xml = replace(replace(data.http.datadog_idp_metadata.response_body, "/(?s)<Signature[^>]*>.*?<\\/Signature>/", ""), "/ ID=\"_[0-9a-fA-F-]+\"/", " ID=\"_stable\"" )
}

resource "datadog_saml_idp_metadata" "this" {
  idp_metadata = local.cleaned_xml
}