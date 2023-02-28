variable "docker_image" {
    type        = string
    default     = null
    description = "Docker image id"
}

variable "container_names" {
    type        = list
    default     = null
    description = "List of container names, equal to container count"
}

variable "commands" {
    type        = list
    default     = null
    description = "Commands to execute after start"
}

variable "entrypoint" {
    type        = list
    default     = null
    description = "Container entrypoint command"
}

variable "tty" {
    type        = bool
    default     = false
    description = "allocate a pseudo-teletype"
}

variable "attach" {
    type        = bool
    default     = false
    description = "Attach container tty"
}

variable "stdin_open" {
    type        = bool
    default     = false
    description = "Left stdin opened"
}

variable "env_vars" {
    type    = set(string) 
    default = null
    description = " | ['key=value', 'key=value'] "
}

variable "network_name" {
    type        = string
    default     = null
    description = "Name of the network to connect"
}

variable "ipv4_address" {
    type        = list
    default     = null
    description = "Set ipv4 address, only custom networks"
}

variable "ports" {
    type        = list
    default     = []
    description = "Internal/External ports to expose | [ 22, 2222 ]"
}

variable "volumes" {
    type        = list
    default     = []
    description = "Volumes to create | [ '/host_path', '/container_path' ] "
}
