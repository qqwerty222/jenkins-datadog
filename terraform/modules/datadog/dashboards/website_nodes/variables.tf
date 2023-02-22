variable "dashboard_title" {
    type    = string
    default = "default"
}

variable "dashboard_description" {
    type    = string
    default = "Created using Terraform"
}

variable "dashboard_layout_type" {
    type    = string
    default = "ordered" 
}

variable "dashboard_is_read_only" {
    type    = bool
    default = false
}

variable "timeseries_title" {
    type    = string
    default = null
}

variable "timeseries_live_span" {
    type    = string
    default = "1h"
}

variable "timeseries_requests" {
    type    = list(map(string))
    default = null
}

variable "timeseries_event" {
    type    = list
    default = [ "tags:terraform" ] 
}
variable "style_params" {
    type        = map
    default     = {
        palette     = "dog_classic"
        line_type   = "solid"
        line_width  = "normal"
    }
}





