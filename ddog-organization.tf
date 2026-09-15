
resource "datadog_organization_settings" "organization" {
  name = var.datadog_organization_name
  settings {
    saml {
      enabled = true
    }
    saml_strict_mode {
      enabled = false
    }
    saml_idp_initiated_login {
      enabled = true
    }
    saml_autocreate_users_domains {
      enabled = true
      domains = var.saml_autocreate_users_domains
    }
    private_widget_share        = false
    saml_autocreate_access_role = var.saml_autocreate_access_role
  }
}