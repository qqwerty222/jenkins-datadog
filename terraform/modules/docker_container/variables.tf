variable "container_name" {
    type    = string
    default = null
}

variable "hostname" {
    type    = string
    default = null
}

variable "docker_image" {
    type    = string
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

variable "stdin_open" {
    type    = bool
    default = false
}

variable "internal_port" {
    type    = number
    default = null
}

variable "external_port" {
    type    = number
    default = null
}

variable "host_path" {
    type    = string
    default = null
}

variable "container_path" {
    type    = string
    default = null
}
