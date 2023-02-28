variable "name" {
    type        = string
    default     = null
    description = "Name of the dasboard list"
}

variable "dashboard_list" {
    type        = list
    default     = null
    description = "Dasboard name and id | [ ['custom_timeboard', module.dashboard.id ] ]"
}

