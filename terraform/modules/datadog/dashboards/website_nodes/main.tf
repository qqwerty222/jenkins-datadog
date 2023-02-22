resource "datadog_dashboard" "website_nodes" {
    
  title        = var.dashboard_title
  description  = var.dashboard_description
  layout_type  = var.dashboard_layout_type

  widget {
    timeseries_definition {
      title       = var.timeseries_title
      show_legend = true
      legend_size = "auto"
      live_span   = var.timeseries_live_span

      request {
        dynamic "query" {
          for_each = var.timeseries_requests
          content {
            metric_query {
                name  = query.value["name"]
                query = query.value["query"]
            }
          }
        }
      }

      dynamic "event" {
        for_each = var.timeseries_event
        content {
          q = event.value
        } 
      }

      # yaxis {
      #   scale        = "linear"
      #   include_zero = true
      #   # max          = 1000
      # }
    }
  }
}