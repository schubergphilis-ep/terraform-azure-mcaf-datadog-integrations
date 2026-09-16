# The variables below are for Datadog
variable "datadog_organization_name" {
  description = "The Datadog organization name"
  type        = string
}

# The variables below are for Datadog
variable "datadog_url" {
  description = "The Datadog organization name"
  type        = string
}

variable "datadog_integration_azure_config" {
  description = "Datadog Azure Integration config"
  type = object({
    tenant_name              = string
    monitored_scope          = string
    host_filters             = optional(list(string), [])
    app_service_plan_filters = optional(list(string), [])
    container_app_filters    = optional(list(string), [])
    automute                 = optional(bool, false)
    cspm_enabled             = optional(bool, false)
    custom_metrics_enabled   = optional(bool, false)
  })
}

variable "datadog_teams" {
  description = "Datadog team configuration"
  type = map(
    object({
      description = string
    })
  )
  default = {}
}

# The variables below are for the integration of Datadog with Opsgenie
variable "opsgenie_integration" {
  description = "OpsGenie integration configuration"
  type = list(object({
    name        = string
    region      = string
    secret_name = string
  }))
  default = []
}

# The variables below are for the integration of Datadog with Slack
variable "slack_integration_pager" {
  description = "Slack integration configuration for Pager alerts"
  type = object({
    account_name     = string
    channel_name     = string
    display_message  = bool
    display_notified = bool
    display_snapshot = bool
    display_tags     = bool
  })
  default = null
}

variable "slack_integration_monitoring" {
  description = "Slack integration configuration for Monitoring"
  type = object({
    account_name     = string
    channel_name     = string
    display_message  = bool
    display_notified = bool
    display_snapshot = bool
    display_tags     = bool
  })
  default = null
}

# Entra ID
variable "saml_autocreate_users_domains" {
  type        = list(string)
  description = "List of domains where the SAML automated user creation is enabled"
}

variable "saml_autocreate_access_role" {
  type    = string
  default = "ro"
  validation {
    condition     = contains(["ro", "st", "adm", "ERROR"], var.saml_autocreate_access_role)
    error_message = "Valid value is one of the following: `ro`, `st`, `adm`, `ERROR`"
  }
}

variable "saml_notification_email_addresses" {
  type        = list(string)
  description = "List of email addresses to receive SAML certificate expiry notifications."
  validation {
    condition = alltrue([
      for email in var.saml_notification_email_addresses :
      can(regex("^[\\w._%+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "Each value in saml_notification_email_addresses must be a valid email address."
  }
  default = [""]
}

variable "saml_assigned_groups" {
  type        = set(string)
  description = "List of Azure Entra ID group display names to assign to the Enterprise Application"
  default     = []
}

variable "owners" {
  type = set(string)
}