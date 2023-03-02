module "dashboard_list" {
    source      = "../modules/datadog/dashboard_list"

    name  = "terraform"
    dashboard_list = [ ["custom_timeboard", module.website_nodes_dashboard.id ] ]

    providers   = {
        datadog = datadog.ddog
    }
}

module "website_nodes_dashboard" {
    source = "../modules/datadog/dashboard_resource"

    dashboard_title       = "Website nodes"
    dashboard_description = "Created by Terraform"
    dashboard_layout_type = "ordered"

    piechart_widgets   = [
        {
            title = "All container CPU Usage"

                live_span          = "4h"
                formula_expression = "query1"
                piechart_requests  = [
                    { name = "query1", query = "avg:container.cpu.usage{container_name:*} by {container_name}" }
                ]
        },

        {
            title = "Web container CPU Usage"

                live_span          = "4h"
                formula_expression = "web_nodes"
                piechart_requests  = [
                    { name = "web_nodes", query = "avg:container.cpu.usage{container_name:website_node*} by {container_name}" }
                ]
        },
    ]

    timeseries_widgets = [
        {
            title = "Web containers CPU Usage"

                legend_size         = "auto"
                show_legend         = true
                live_span           = "4h"

                timeseries_requests = [
                    for name in module.website_node.container_names: 
                        { name = "web_cont${index(module.website_node.container_names, name) + 1}",  query = "avg:container.cpu.usage{container_name:${name}} by {container_name}"}

                    # { name = "web_cont_1", query = "avg:container.cpu.usage{container_name:website_node1} by {container_name}" },
                    # { name = "web_conf_2", query = "avg:container.cpu.usage{container_name:website_node2} by {container_name}" },
                    # { name = "web_conf_3", query = "avg:container.cpu.usage{container_name:website_node3} by {container_name}" },
                ],
                timeseries_events = ["tags:terraform", "tags:web_containers"]
        },

        {
            title = "Nginx CPU Usage"

                show_legend         = true
                legend_size         = "auto"
                live_span           = "1h"
                timeseries_requests = [
                    for name in module.nginx_node.container_names: 
                        { name = "ngx_cont${index(module.nginx_node.container_names, name) + 1}",  query = "avg:container.cpu.usage{container_name:${name}} by {container_name}"}
                    
                    # { name = "dockerhost", query = "avg:container.cpu.system{container_name:nginx_node1}" },
                ]
                timeseries_events   = ["tags:terraform", "tags:nginx"]
        },

        {
            title = "DockerHost CPU Usage"

                show_legend           = true
                legend_size           = "auto"
                live_span             = "1h"
                timeseries_requests   = [
                    { name = "dockerhost", query = "avg:system.cpu.system{host:dockerhost}" },
                ]
                timeseries_events    = ["tags:terraform"]
        },

        {
            title = "Nginx AVG response time"

                show_legend           = true
                live_span             = "1h"
                legend_size           = "auto"
                timeseries_requests   = [
                    { name = "dockerhost", query = "avg:custom.nginx.ping.avg{host:dockerhost}" },
                ]
                timeseries_events    = ["tags:terraform", "tags:nginx"]
        },
    ]

    summary_widgets = [
        {
            title = "Monitor Summary"
                
                summary_type     = "monitors"
                display_format   = "countsAndList"
                color_preference = "background" 
                sort             = "status"

                query = "tag:(created:terraform)"
        },
    ]

    providers   = {
        datadog = datadog.ddog
    }
}

module "monitor" {
    source   = "../modules/datadog/monitors"

    monitors = [
        {
            mon_name = "Website availability"
            
                mon_type           = "metric alert"
                alert_message      = "Monitor triggered. Notify: @example-group"
                escalation_message = "Escalation message @pagerduty"

                query              = "avg(last_5m):(%{ for name in module.website_node.container_names} + avg:custom.${name}.availability{*} %{ endfor } ) / 3 < 30 "
                                   # "avg(last_5m):(avg:custom.website_node1.availability{*} + avg:custom.website_node2.availability{*} + avg:custom.website_node3.availability{*}) / 3 < 30"

                warning_threshold  = 70
                critical_threshold = 30
                
                include_tags       = true
                tags               = [ "created:terraform", "tags:web_containers" ]
        },  
    ]

    providers   = {
        datadog = datadog.ddog
    }
}

