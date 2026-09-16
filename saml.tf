resource "random_uuid" "saml_uuids" {
  for_each = toset(["user"])
}

resource "azuread_application" "datadog_saml_auth" {
  display_name     = "Datadog"
  sign_in_audience = "AzureADMyOrg"
  owners           = var.owners
  logo_image       = filebase64("${path.module}/dd_icon_rgb.png")
  notes            = "Managed by Terraform. Datadog EU SAML SSO. Do not edit manually."

  # cannot be set at create time for a domain you don't own
  identifier_uris = []

  group_membership_claims = ["ApplicationGroup"]

  app_role {
    id                   = random_uuid.saml_uuids["user"].result
    allowed_member_types = ["User"]
    display_name         = "User"
    description          = "Datadog user"
    enabled              = true
  }
  
  web {
    redirect_uris = [
      "https://app.${var.datadog_url}/account/saml/assertion",
      "https://app.${var.datadog_url}/account/saml/assertion/id/${data.datadog_organization_settings.organization.id}",
    ]
  }
  lifecycle {
    ignore_changes = [identifier_uris]
  }
}

resource "azuread_claims_mapping_policy" "datadog_saml_auth" {
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

resource "azuread_service_principal" "datadog_saml_auth" {
  client_id                     = azuread_application.datadog_saml_auth.client_id
  preferred_single_sign_on_mode = "saml"

  app_role_assignment_required = true
  login_url                    = "https://app.${var.datadog_url}/account/login/id/${data.datadog_organization_settings.organization.id}"
  notification_email_addresses = var.saml_notification_email_addresses
  feature_tags {
    enterprise            = true
    custom_single_sign_on = true
  }
}

resource "azuread_application_identifier_uri" "datadog_saml_auth" {
  application_id = azuread_application.datadog_saml_auth.id
  identifier_uri = "https://app.${var.datadog_url}/account/saml/metadata.xml"

  depends_on = [azuread_service_principal.datadog_saml_auth]
}

resource "azuread_service_principal_claims_mapping_policy_assignment" "app" {
  claims_mapping_policy_id = azuread_claims_mapping_policy.datadog_saml_auth.id
  service_principal_id     = azuread_service_principal.datadog_saml_auth.id
}

resource "time_rotating" "certificate_expiration" {
  rotation_years = 3
}

resource "azuread_service_principal_token_signing_certificate" "saml_signing_cert" {
  service_principal_id = azuread_service_principal.datadog_saml_auth.id
  display_name         = "CN=DataDog SAML SSO Certificate"
  end_date             = time_rotating.certificate_expiration.rotation_rfc3339
}

resource "azuread_app_role_assignment" "group_assignments" {
  for_each = data.azuread_group.sso_groups

  app_role_id         = random_uuid.saml_uuids["user"].result
  principal_object_id = each.value.object_id
  resource_object_id  = azuread_service_principal.datadog_saml_auth.object_id
}

resource "datadog_authn_mapping" "group_assignments" {
  for_each = data.azuread_group.sso_groups

  key   = "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
  value = each.value.object_id
  role  = one([for r in data.datadog_roles.all.roles : r.id if r.name == var.saml_assigned_groups[each.key].role])
}

resource "time_sleep" "metadata_availability" {
  create_duration = "60s"
  depends_on = [
    azuread_service_principal_token_signing_certificate.saml_signing_cert,
    azuread_application.datadog_saml_auth,
    azuread_application_identifier_uri.datadog_saml_auth,
    azuread_service_principal_claims_mapping_policy_assignment.app,
  ]
}

data "http" "datadog_idp_metadata" {
  url = "https://login.microsoftonline.com/${var.datadog_integration_azure_config.tenant_name}/federationmetadata/2007-06/federationmetadata.xml?appid=${azuread_service_principal.datadog_saml_auth.client_id}"

  request_headers = {
    Accept = "application/xml"
  }

  depends_on = [time_sleep.metadata_availability]
}

locals {
  cleaned_xml = replace(replace(data.http.datadog_idp_metadata.response_body, "/(?s)<Signature[^>]*>.*?<\\/Signature>/", ""), "/ ID=\"_[0-9a-fA-F-]+\"/", " ID=\"_stable\"")
}

resource "datadog_saml_idp_metadata" "this" {
  idp_metadata = local.cleaned_xml
}