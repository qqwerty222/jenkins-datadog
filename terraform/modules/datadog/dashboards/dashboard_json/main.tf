resource "datadog_dashboard_json" "common" {
    count = length(var.dashboards)
    dashboard = var.dashboard_json[count.index]
}
