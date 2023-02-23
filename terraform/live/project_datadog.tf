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
    
    piechart_widgets   = [
        {
            title     = "All container CPU Usage"
            live_span = "4h"
            formula_expression = "query1"

            piechart_requests = [
                { name = "query1", query = "avg:container.cpu.usage{container_name:*} by {container_name}" }
            ]
        },

        {
            title     = "Web container CPU Usage"
            live_span = "4h"
            formula_expression = "web_nodes"

            piechart_requests = [
                { name = "web_nodes", query = "avg:container.cpu.usage{container_name:website_node*} by {container_name}" }
            ]
        }
    ]

    timeseries_widgets = [
        {
            title       = "Web containers CPU Usage",
            legend_size = "auto",
            show_legend = true,
            live_span   = "4h",

            timeseries_requests   = [
                { name = "web_cont_1", query = "avg:container.cpu.usage{container_name:website_node1} by {container_name}" },
                { name = "web_conf_2", query = "avg:container.cpu.usage{container_name:website_node2} by {container_name}" },
                { name = "web_conf_3", query = "avg:container.cpu.usage{container_name:website_node3} by {container_name}" }
            ],

            timeseries_events    = ["tags:terraform"]
        },

        {
            title       = "Nginx CPU Usage",
            show_legend = true,
            legend_size = "auto",
            live_span   = "1h",

            timeseries_requests   = [
                { name = "dockerhost", query = "avg:container.cpu.system{container_name:nginx_node}" }
            ],

            timeseries_events    = ["tags:terraform", "tags:nginx"]
        },

        {
            title       = "DockerHost CPU Usage",
            show_legend = true,
            legend_size = "auto",
            live_span   = "1h",

            timeseries_requests   = [
                { name = "dockerhost", query = "avg:system.cpu.system{host:dockerhost}" }
            ],

            timeseries_events    = ["tags:terraform", "tags:nginx"]
        }
    ]

    providers   = {
        datadog = datadog.ddog
    }
}



