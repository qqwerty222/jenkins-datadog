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
    
    timeseries_widgets = [
        {
            title       = "Widget 1",
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
            title       = "Widget 2",
            legend_size = "auto",
            show_legend = true,
            live_span   = "4h",

            timeseries_requests   = [
                { name = "web_cont_3", query = "avg:container.cpu.usage{container_name:website_node3} by {container_name}" },
                { name = "web_conf_2", query = "avg:container.cpu.usage{container_name:website_node2} by {container_name}" },
                { name = "web_conf_1", query = "avg:container.cpu.usage{container_name:website_node1} by {container_name}" }
            ],

            timeseries_events    = ["tags:terraform2"]
        }
    ]

    providers   = {
        datadog = datadog.ddog
    }
}



