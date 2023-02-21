resource "datadog_dashboard" "website_nodes" {
    
  title        = var.title
  description  = var.description
  layout_type  = var.layout_type
  is_read_only = var.is_read_only

  widget {
    timeseries_definition {
      title       = "Website Nodes"
      show_legend = true
      legend_size = "2"
      live_span   = "1h"

      request {
        query {
          metric_query {
            data_source = "metrics"
            query       = "avg:container.cpu.usage{container_name:website_node1} by {container_name}"
            name        = "query_1"
            # aggregator  = "sum"
          }
        }
        query {
          metric_query {
            data_source = "metrics"
            query       = "avg:container.cpu.usage{container_name:website_node2} by {container_name}"
            name        = "query_2"
            # aggregator  = "sum"
          }
        }
      }

      event {
        q = "sources:test tags:1"
      }

      yaxis {
        scale        = "linear"
        include_zero = true
        # max          = 1000
      }
    }
  }
}