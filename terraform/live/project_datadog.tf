module "dashboard_list" {
    source      = "../modules/datadog/dashboard_list"

    name  = "terraform"
    dashboard_list = [ ["custom_timeboard", module.website_nodes_dashboard.id ] ]

    providers   = {
        datadog = datadog.ddog
    }
}

module "website_nodes_dashboard" {
    source = "../modules/datadog/dashboards/website_nodes"

    dashboard_title       = "Website nodes"
    dashboard_description = "Created by Terraform"
    
    timeseries_title      = "CPU Usage (AVG)"
    timeseries_live_span  = "4h"
    timeseries_requests   = [
        { name = "web_cont_1", query = "avg:container.cpu.usage{container_name:website_node1} by {container_name}" },
        { name = "web_conf_2", query = "avg:container.cpu.usage{container_name:website_node2} by {container_name}" },
        { name = "web_conf_3", query = "avg:container.cpu.usage{container_name:website_node3} by {container_name}" }
    ] 

    timeseries_event        = ["tags:terraform"]

    providers   = {
        datadog = datadog.ddog
    }
}



