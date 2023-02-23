variable "DATADOG_API_KEY" {
    type      = string
    default   = null
    sensitive = true
}

variable "DATADOG_APP_KEY" {
    type      = string
    default   = null
    sensitive = true
    
}

variable "api_url" {
    type    = string
    default = null
}

