resource "datadog_monitor" "common" {
    count = length(var.monitors)

    name                = var.monitors[count.index]["mon_name"]
    type                = var.monitors[count.index]["mon_type"]
    message             = var.monitors[count.index]["alert_message"]
    escalation_message  = var.monitors[count.index]["escalation_message"]

    query               = var.monitors[count.index]["query"]

    monitor_thresholds {
        warning         = var.monitors[count.index]["warning_threshold"]
        critical        = var.monitors[count.index]["critical_threshold"]
    }

    include_tags        = var.monitors[count.index]["include_tags"]

    tags                = var.monitors[count.index]["tags"]
}

