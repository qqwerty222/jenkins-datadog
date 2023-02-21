# resource "datadog_dashboard" "free_dashboard" {
#     title        = "Website nodes"
#     description  = "Created using the Datadog provider in Terraform"
#     layout_type  = "ordered"
#     is_read_only = false

#     widget {
#         timeseries_definition {
#             title       = "Website Nodes"
#             show_legend = true
#             legend_size = "2"
#             live_span   = "1h"

            # request {
            #     query {
            #         metric_query {
            #             data_source = "metrics"
            #             query       = "avg:container.cpu.usage{container_name:website_node1} by {container_name}"
            #             name        = "my_query_1"
            #             aggregator  = "sum"
            #         }
            #     }
#                 query {
#                     metric_query {
#                         query      = "avg:container.cpu.usage{container_name:website_node2} by {container_name}"
#                         name       = "my_query_2"
#                         aggregator = "sum"
#                     }
#                 }
#             }

#             yaxis {
#                 scale        = "linear"
#                 include_zero = true
#                 # max          = 1000
#             }
#         }
#     }
# }
