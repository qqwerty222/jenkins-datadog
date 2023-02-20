module "dashboard_list" {
    source = "../modules/datadog/dashboard_list"

    name      = "terraform"
    dashboards = [
        ["custom_timeboard", module.dashboards.ids]
    ] 
}

module "dashboards" {
    source = "../modules/datadog/dashboards"

    dashboard_json = [
        file("dashboards_json/website_nodes.json")
    ]
}