variable "monitors" {
    description = "List of objects that contain parameters of monitor"
    type = list(object({
        mon_name           = string
        mon_type           = string
        alert_message      = string
        escalation_message = string

        query              = string

        warning_threshold  = number
        critical_threshold = number

        include_tags       = bool
        tags               = list(string)
    }))
    
    default = [
        {
            mon_name           = null
            mon_type           = "metric alert"
            alert_message      = "Monitor triggered. Notify: @example-group"
            escalation_message = "Escalation message @pagerduty"

            query              = null

            warning_threshold  = null
            critical_threshold = null

            include_tags       = true
            tags               = [ "created:terraform" ]
        }
    ]
}