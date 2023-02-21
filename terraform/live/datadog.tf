module "dashboards" {
    source      = "../modules/datadog/dashboards"

    dashboards     = [ "website_nodes" ]
    dashboard_json = [
        file("dashboards_json/website_nodes.json")
    ]

    providers   = {
        datadog = datadog.ddog
    }
}

module "dashboard_list" {
    source      = "../modules/datadog/dashboard_list"

    name  = "terraform"
    dashboard_list = [ for x in module.dashboards.ids : ["custom_timeboard", x] ]

    providers   = {
        datadog = datadog.ddog
    }
}

