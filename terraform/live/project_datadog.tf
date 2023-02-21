# module "json_dashboard" {
#     source = "../modules/datadog/dashboards"

#     dashboards     = [ "website_nodes" ]
#     dashboard_json = [
#         file("dashboards_json/website_nodes.json")
#     ]

#     providers   = {
#         datadog = datadog.ddog
#     }
# }

module "website_nodes_dashboard" {
    source = "../modules/datadog/dashboards/website_nodes"

    title   = "Created by Terraform"
    request = "avg:container.cpu.usage{container_name:website_node1} by {container_name}"
    
    providers   = {
        datadog = datadog.ddog
    }
}

# module "dashboard_list" {
#     source      = "../modules/datadog/dashboard_list"

#     name  = "terraform"
#     dashboard_list = [ for x in module.json_dashboard.ids : ["custom_timeboard", x] ]

#     providers   = {
#         datadog = datadog.ddog
#     }
# }

