variable "network_name" {
    type        = string
    default     = null
    description = "Name of network to create"
}

variable "ipam_config" {
    type        = list
    default     = null
    description = " | ipam_config = [ subnet/16, ip_range/24, gateway.254 ]"
}