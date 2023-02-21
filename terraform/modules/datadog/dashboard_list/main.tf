resource "datadog_dashboard_list" "common" {
    name = var.name
    
    dynamic "dash_item" {
      for_each = var.dashboard_list
      content {
        type    = dash_item.value[0]
        dash_id = dash_item.value[1]
      }
    }
}






 