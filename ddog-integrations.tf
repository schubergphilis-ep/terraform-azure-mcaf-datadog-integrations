# resource "datadog_integration_slack_channel" "slack_integration_pager" {
#   count = var.slack_integration_pager == null ? 0 : 1
# 
#   account_name = var.slack_integration_pager.account_name
#   channel_name = var.slack_integration_pager.channel_name
# 
#   display {
#     message  = var.slack_integration_pager.display_message
#     notified = var.slack_integration_pager.display_notified
#     snapshot = var.slack_integration_pager.display_snapshot
#     tags     = var.slack_integration_pager.display_tags
#   }
# }
# 
# resource "datadog_integration_slack_channel" "slack_integration_monitoring" {
#   count = var.slack_integration_monitoring == null ? 0 : 1
# 
#   account_name = var.slack_integration_monitoring.account_name
#   channel_name = var.slack_integration_monitoring.channel_name
# 
#   display {
#     message  = var.slack_integration_monitoring.display_message
#     notified = var.slack_integration_monitoring.display_notified
#     snapshot = var.slack_integration_monitoring.display_snapshot
#     tags     = var.slack_integration_monitoring.display_tags
#   }
# }
# 
# resource "datadog_integration_opsgenie_service_object" "opsgenie_integration" {
#   for_each = { for idx, opsgenie_integration in var.opsgenie_integration : idx => opsgenie_integration }
# 
#   name             = each.value.name
#   opsgenie_api_key = data.azurerm_key_vault_secret.opsgenie_api_key[each.key].value
#   region           = each.value.region
# }
