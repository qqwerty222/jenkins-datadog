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
    description = "Also can be 'free', but you need to specify size and position of each widget"
}

variable "dashboard_is_read_only" {
    type    = bool
    default = false
}

variable "timeseries_widgets" {
    
    description = "List of objects that contain parameters of timeseries widget"
    type = list(object({
        title       = string
        show_legend = bool
        legend_size = string
        live_span   = string

        timeseries_requests = list(map(string))
        timeseries_events   = list(string)
    }))
    default = [
        {
            title       = null
            show_legend = null
            legend_size = "auto"
            live_span   = "4h"

            timeseries_requests = []
            timeseries_events   = ["tags:terraform"]
        }
    ]
}

variable "piechart_widgets" {
    
    description = "List of objects that contain parameters of piechart widget"
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

variable "summary_widgets" {
    
    description = "List of objects that contain parameters of summary widget"
    type = list(object({
        title = string
            summary_type     = string
            display_format   = string
            color_preference = string
            sort             = string

            query            = string
    }))
    default = [
        {   
            title = null
                summary_type     = "monitors"
                display_format   = "list"
                color_preference = "background"
                sort             = "status"

                query = null
        }
    ]

}






