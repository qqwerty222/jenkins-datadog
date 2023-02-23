variable "docker_image" {
    type    = string
    default = null
}

variable "container_names" {
    type    = list
    default = null
}

variable "commands" {
    type    = list
    default = null
}

variable "entrypoint" {
    type    = list
    default = null
}

variable "tty" {
    type    = bool
    default = false
}

variable "attach" {
    type    = bool
    default = false
}

variable "stdin_open" {
    type    = bool
    default = false
}

variable "env_vars" {
    type    = set(string) 
    default = null
}

variable "network_name" {
    type    = string
    default = null
}

variable "ipv4_address" {
    type    = list
    default = null
}

variable "ports" {
    type    = list
    default = []
}

variable "volumes" {
    type    = list
    default = []
}
