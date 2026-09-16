resource "random_uuid" "saml_uuids" {
  for_each = toset(["oauth", "user", "group", "msiam"])
}

resource "azuread_application" "datadog_saml_auth_application_registration" {
  display_name            = "Datadog"
  logo_image              = filebase64("${path.module}/dd_icon_rgb.png")
  identifier_uris         = ["https://app.${var.datadog_url}/account/saml/metadata.xml"]
  owners                  = azuread_application.application.owners
  group_membership_claims = ["ApplicationGroup"]

  api {
    known_client_applications      = []
    mapped_claims_enabled          = false
    requested_access_token_version = 1

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access Datadog on behalf of the signed-in user."
      admin_consent_display_name = "Access Datadog"
      enabled                    = true
      id                         = random_uuid.saml_uuids["oauth"].result
      type                       = "User"
      user_consent_description   = "Allow the application to access Datadog on your behalf."
      user_consent_display_name  = "Access Datadog"
      value                      = "user_impersonation"
    }
  }
  app_role {
    allowed_member_types = ["User"]
    description          = "User"
    display_name         = "User"
    enabled              = true
    id                   = random_uuid.saml_uuids["user"].result
  }
  app_role {
    allowed_member_types = ["User"]
    description          = "msiam_access"
    display_name         = "msiam_access"
    enabled              = true
    id                   = random_uuid.saml_uuids["msiam"].result
  }
  app_role {
    allowed_member_types = ["User"]
    description          = "Group role (used by SP for group assignment)"
    display_name         = "Group"
    enabled              = true
    id                   = random_uuid.saml_uuids["group"].result
  }
  web {
    homepage_url = "https://app.${var.datadog_url}/account/saml/assertion?metadata=datadog|ISV9.1|primary|z"
    redirect_uris = [
      "https://app.${var.datadog_url}/account/saml/assertion"
    ]
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  feature_tags {
    enterprise = true
  }
  optional_claims {
    saml2_token {
      name      = "groups"
      essential = false
      additional_properties = [
        "sam_account_name",
        "cloud_displayname"
      ]
    }
  }
}
resource "azuread_application_identifier_uri" "datadog_saml_auth_application_identifier_uri" {
  application_id = azuread_application.datadog_saml_auth_application_registration.id
  identifier_uri = "https://app.${var.datadog_url}/account/saml/metadata.xml"
}

resource "azuread_service_principal" "datadog_saml_auth_enterprise_application" {
  client_id                     = azuread_application.datadog_saml_auth_application_registration.client_id
  app_role_assignment_required  = true
  login_url                     = "https://app.${var.datadog_url}/account/login/id/${datadog_organization_settings.organization.id}"
  preferred_single_sign_on_mode = "saml"
  notification_email_addresses  = var.saml_notification_email_addresses
  feature_tags {
    enterprise            = true
    custom_single_sign_on = true
  }
}
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
  service_principal_id     = azuread_service_principal.datadog_saml_auth_enterprise_application.id
}

resource "time_rotating" "certificate_expiration" {
  rotation_years = 3
}

# Generate and assign a SAML token signing certificate (End Date Validity is 3 years max)
resource "azuread_service_principal_token_signing_certificate" "saml_signing_cert" {
  service_principal_id = azuread_service_principal.datadog_saml_auth_enterprise_application.id
  display_name         = "CN=DataDog SAML SSO Certificate"
  end_date             = time_rotating.certificate_expiration.rotation_rfc3339
}

# Assign Entra ID Groups to the Enterprise Application
resource "azuread_app_role_assignment" "group_assignments" {
  for_each = data.azuread_group.sso_groups

  principal_object_id = each.value.id
  resource_object_id  = azuread_service_principal.datadog_saml_auth_enterprise_application.id

  app_role_id = one([
    for role in azuread_application.datadog_saml_auth_application_registration.app_role :
    role.id if role.display_name == "Group"
  ])
}
