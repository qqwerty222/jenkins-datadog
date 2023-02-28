variable "docker_image" {
    type        = string
    default     = null
    description = "Docker image id"
}

variable "container_count" {
    type        = number
    default     = 1
    description = "Number of conteiners to create"
}

variable "name" {
    type        = string
    default     = "container"
    description = "Base container name, using count next will be name1, name2, name3 etc."
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

variable "network" {
    type = object({
        name            = string
        subnet          = string
        start_from      = number
    })
    default = null
    description = "Set custom network | network = { name='net_1', ipv4_subnet='1.1.1.', ip_started_from='10' }"
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
