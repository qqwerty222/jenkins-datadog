resource "datadog_dashboard_json" "common" {
    count = length(var.dashboards)
    dasboard = var.dashboard_json[count.index]
}

# terraform {
#   required_providers {
#     datadog  = {
#       source = "DataDog/datadog"
#     }
#   }
# }