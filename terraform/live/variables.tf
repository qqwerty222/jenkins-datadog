variable "datadog_api_key" {
    type      = string
    sensitive = true
}

variable "datadog_app_key" {
    type      = string
    sensitive = true
}

variable "api_url" {
    type    = string
    default = null
}

