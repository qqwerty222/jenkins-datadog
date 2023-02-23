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

variable "timeseries_widgets" {
    type = list(object({
        title       = string,
        show_legend = bool,
        legend_size = string,
        live_span   = string,

        timeseries_requests = list(map(string)),
        timeseries_events   = list(string)
    }))
    default = [
        {
            title       = null,
            show_legend = null,
            legend_size = "auto",
            live_span   = "4h",

            timeseries_requests = [],
            timeseries_events   = ["tags:terraform"]
        }
    ]
}

variable "piechart_widgets" {
    type = list(object({
        title     = string, 
        live_span = string,

        formula_expression = string 
        piechart_requests  = list(map(string)),
    }))
    default = [
        { 
            title     = "Pie Chart"
            live_span = "4h"

            formula_expression = "query1"
            piechart_requests  = []
        }
    ]
}






