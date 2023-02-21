variable "title" {
    type    = string
    default = "default"
}

variable "description" {
    type    = string
    default = "Created using Terraform"
}

variable "layout_type" {
    type    = string
    default = "ordered" 
}

variable "is_read_only" {
    type    = bool
    default = false
}

variable "request" {
    type        = string
    default     = null
    description = "query, exmp: 'avg:container.cpu.usage{container_name:website_node1} by {container_name}'"
}

variable "display_type" {
    type        = string
    default     = "area"
    description = "lines, area, bars"
}

variable "style_params" {
    type        = map
    default     = {
        palette     = "dog_classic"
        line_type   = "solid"
        line_width  = "normal"
    }
}



