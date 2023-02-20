resource "datadog_dashboard_list" "common" {
    name = var.name

    dynamic dash_item {
        for_each = var.dashboards 
        content {
            type    = dashboards.value[0]
            dash_id = dashboards.value[1] 
        }
    }
}

# terraform {
#   required_providers {
#     datadog  = {
#       source = "DataDog/datadog"
#     }
#   }
# }