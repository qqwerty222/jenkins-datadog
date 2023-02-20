output "ids" {
    value = datadog_dashboard_json.common[*].id 
}
