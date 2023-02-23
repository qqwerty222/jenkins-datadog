resource "datadog_dashboard" "website_nodes" {

  title        = var.dashboard_title
  description  = var.dashboard_description
  layout_type  = var.dashboard_layout_type

  dynamic "widget" {
    for_each = var.timeseries_widgets
    content {
      timeseries_definition {
          title       = widget.value["title"]
          show_legend = widget.value["show_legend"]
          legend_size = widget.value["legend_size"]
          live_span   = widget.value["live_span"]

          request {
            dynamic "query" {
              for_each = widget.value["timeseries_requests"]
              content {
                metric_query {
                    name  = query.value["name"]
                    query = query.value["query"]
                }
              }
            }
          }

          dynamic "event" {
            for_each = widget.value["timeseries_events"]
            content {
              q = event.value
            } 
          }

          yaxis {
            scale        = "linear"
            include_zero = true
            # max          = 1000
          }
         
      }
    }
  }

  dynamic "widget" {
    for_each = var.piechart_widgets
    content {
      sunburst_definition {
        title         = widget.value["title"]
        live_span     = widget.value["live_span"]

        # legend_table {
        #   type         = "table"
        # }
        
        request {
          formula {
            formula_expression = widget.value["formula_expression"]
            limit {
              order = "desc"
            }
          }

          dynamic "query" {
            for_each = widget.value["piechart_requests"]
            content {
              metric_query {
                name  = query.value["name"]
                query = query.value["query"]
                aggregator = "sum"
              }  
            }
          }
        }
      }
    }
  }
}
