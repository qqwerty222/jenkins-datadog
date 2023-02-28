variable "DATADOG_API_KEY" {
    type        = string
    default     = null
    sensitive   = true
    description = "Set as env var, to use datadog"
}

variable "DATADOG_APP_KEY" {
    type        = string
    default     = null
    sensitive   = true
    description = "Set as env var, to use datadog"
}

variable "api_url" {
    type        = string
    default     = null
    description = "Site url, can be datadoghq.eu, datadoghq.com etc."
}

